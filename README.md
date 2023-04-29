# terraform-python-lambda

This is a Terraform module for creating a single, standalone Python Lambda.
I use it when I want to use Lambda for some piece of one-off data processing – it doesn't need to be permanent infrastructure and I don't want to spend too long on it, I just want to run some Python inside AWS.

This is what it creates:

<img src="architecture.svg">

The Lambda reads from an SNS topic as input, writes any logs to CloudWatch, and sends its output to SQS.
