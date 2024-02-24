# ServiceRole for GLUE
resource "aws_iam_role" "glue" {
  name               = var.name_role_glue
  tags               = var.tags
  path               = "/"
  description        = "Rule allowing to handle glue and its features"
  assume_role_policy = file("./permissions/role_glue.json")
}

resource "aws_iam_policy" "glue" {
  name        = var.name_policy_glue
  tags        = var.tags
  path        = "/"
  description = "Policy allowing to handle especific datalake bucket."
  policy      = file("./permissions/policy_glue.json")
}

resource "aws_iam_role_policy_attachment" "glue_attach" {
  role       = aws_iam_role.glue.name
  policy_arn = aws_iam_policy.glue.arn
}

resource "aws_iam_role_policy_attachment" "glue_attach_AWSGlueServiceRole" {
  role       = aws_iam_role.glue.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "glue_attach_AWSGlueConsoleFullAccess" {
  role       = aws_iam_role.glue.name
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}