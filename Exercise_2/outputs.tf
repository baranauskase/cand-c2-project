# TODO: Define the output variable for the lambda function.
output "udacity_cand_c2_lambda_greeting" {
    value = "${aws_lambda_function.udacity_cand_c2_lambda.environment[0].variables["greeting"]}"
}