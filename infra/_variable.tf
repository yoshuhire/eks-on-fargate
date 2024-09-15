#############
# 環境区分
#############
variable "env" {
  description = "本開区分の指定(prd or dev)"
  type        = string

  validation {
    condition     = contains(["dev", "prd"], var.env)
    error_message = "env must be either dev or prd"
  }
}
