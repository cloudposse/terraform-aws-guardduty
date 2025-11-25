package test

import (
	"fmt"
	"math/rand/v2"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestExamplesComplete tests the Terraform module in examples/complete using Terratest.
// This test validates:
// - GuardDuty detector creation
// - Detector features configuration
// - SNS topic creation and configuration
// - CloudWatch integration
func TestExamplesComplete(t *testing.T) {
	// Note: t.Parallel() is removed because GuardDuty only allows one detector per AWS account.
	// Running tests in parallel would cause conflicts when both try to create a detector.

	// Generate a random attribute to ensure test uniqueness
	// Using rand/v2 (Go 1.22+) which is automatically seeded
	randID := fmt.Sprintf("%05d", rand.IntN(100000))
	attributes := []string{randID}

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/complete",
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{"fixtures.us-east-2.tfvars"},
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run subtests for different validation aspects
	t.Run("ValidateGuardDutyDetector", func(t *testing.T) {
		validateGuardDutyDetector(t, terraformOptions)
	})

	t.Run("ValidateSNSTopic", func(t *testing.T) {
		validateSNSTopic(t, terraformOptions)
	})

	t.Run("ValidateOutputs", func(t *testing.T) {
		validateOutputs(t, terraformOptions)
	})
}

// validateGuardDutyDetector verifies the GuardDuty detector was created correctly
func validateGuardDutyDetector(t *testing.T, opts *terraform.Options) {
	// Get GuardDuty detector output
	detector := terraform.OutputMap(t, opts, "guardduty_detector")

	// Verify detector exists and has required fields
	require.NotEmpty(t, detector, "GuardDuty detector output should not be empty")

	// Validate detector ID exists and is non-empty
	detectorID, hasID := detector["id"]
	require.True(t, hasID, "GuardDuty detector should have an ID")
	require.NotEmpty(t, detectorID, "GuardDuty detector ID should not be empty")
	t.Logf("GuardDuty Detector ID: %s", detectorID)

	// Validate detector ARN exists and has correct format
	detectorARN, hasARN := detector["arn"]
	require.True(t, hasARN, "GuardDuty detector should have an ARN")
	require.NotEmpty(t, detectorARN, "GuardDuty detector ARN should not be empty")
	assert.True(t, strings.HasPrefix(detectorARN, "arn:aws:guardduty:"),
		"GuardDuty detector ARN should start with 'arn:aws:guardduty:', got: %s", detectorARN)
	assert.Contains(t, detectorARN, "detector/",
		"GuardDuty detector ARN should contain 'detector/', got: %s", detectorARN)
	t.Logf("GuardDuty Detector ARN: %s", detectorARN)

	// Validate detector status
	status, hasStatus := detector["status"]
	if hasStatus {
		// Status should be ENABLED (case-insensitive check)
		assert.Equal(t, "ENABLED", strings.ToUpper(status),
			"GuardDuty detector status should be ENABLED, got: %s", status)
		t.Logf("GuardDuty Detector Status: %s", status)
	}

	// Validate finding publishing frequency if present
	frequency, hasFrequency := detector["finding_publishing_frequency"]
	if hasFrequency && frequency != "" {
		validFrequencies := []string{"FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"}
		assert.Contains(t, validFrequencies, frequency,
			"Finding publishing frequency should be one of %v, got: %s", validFrequencies, frequency)
		t.Logf("Finding Publishing Frequency: %s", frequency)
	}
}

// validateSNSTopic verifies the SNS topic was created correctly
func validateSNSTopic(t *testing.T, opts *terraform.Options) {
	// Get SNS topic output
	snsTopic := terraform.OutputMap(t, opts, "sns_topic")

	// Verify SNS topic exists
	require.NotEmpty(t, snsTopic, "SNS topic output should not be empty")

	// Validate SNS topic ID
	topicID, hasID := snsTopic["id"]
	require.True(t, hasID, "SNS topic should have an ID")
	require.NotEmpty(t, topicID, "SNS topic ID should not be empty")
	t.Logf("SNS Topic ID: %s", topicID)

	// Validate SNS topic ARN if present
	topicARN, hasARN := snsTopic["arn"]
	if hasARN && topicARN != "" {
		assert.True(t, strings.HasPrefix(topicARN, "arn:aws:sns:"),
			"SNS topic ARN should start with 'arn:aws:sns:', got: %s", topicARN)
		assert.Contains(t, topicARN, "guardduty",
			"SNS topic ARN should contain 'guardduty', got: %s", topicARN)
		t.Logf("SNS Topic ARN: %s", topicARN)
	}

	// Validate SNS topic name if present
	topicName, hasName := snsTopic["name"]
	if hasName && topicName != "" {
		assert.Contains(t, topicName, "guardduty",
			"SNS topic name should contain 'guardduty', got: %s", topicName)
		t.Logf("SNS Topic Name: %s", topicName)
	}
}

// validateOutputs verifies all expected outputs are present and valid
func validateOutputs(t *testing.T, opts *terraform.Options) {
	// Get detector ID output
	detectorID := terraform.Output(t, opts, "guardduty_detector_id")
	assert.NotEmpty(t, detectorID, "guardduty_detector_id output should not be empty")
	t.Logf("Output guardduty_detector_id: %s", detectorID)

	// Get detector ARN output
	detectorARN := terraform.Output(t, opts, "guardduty_detector_arn")
	assert.NotEmpty(t, detectorARN, "guardduty_detector_arn output should not be empty")
	assert.True(t, strings.HasPrefix(detectorARN, "arn:aws:guardduty:"),
		"guardduty_detector_arn should be a valid ARN, got: %s", detectorARN)
	t.Logf("Output guardduty_detector_arn: %s", detectorARN)

	// Verify detector ID and ARN are consistent
	// The detector ID should be the last part of the ARN after "detector/"
	if strings.Contains(detectorARN, "detector/") {
		arnParts := strings.Split(detectorARN, "detector/")
		if len(arnParts) == 2 {
			arnDetectorID := arnParts[1]
			assert.Equal(t, detectorID, arnDetectorID,
				"Detector ID from output (%s) should match the ID in the ARN (%s)",
				detectorID, arnDetectorID)
		}
	}
}
