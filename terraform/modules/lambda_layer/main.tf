variable "source_path" {
  description = "The path to the source code"
  type        = string
  default     = "../../dist"
}

variable "layer_name" {
  description = "The name of the layer"
  type        = string
}

data "archive_file" "lambda_zip" {
  type             = "zip"
  source_dir       = "${var.source_path}/layers/${var.layer_name}/"
  output_file_mode = "0666"
  output_path      = "${var.source_path}/layers/${var.layer_name}.zip"
}

resource "aws_lambda_layer_version" "layer" {
  layer_name               = var.layer_name
  filename                 = data.archive_file.lambda_zip.output_path
  source_code_hash         = data.archive_file.lambda_zip.output_base64sha256
  compatible_runtimes      = ["nodejs20.x"]
  compatible_architectures = ["arm64"]
}

output "arn" {
  value = aws_lambda_layer_version.layer.arn
}
