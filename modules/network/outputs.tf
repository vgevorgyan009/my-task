output "vpc" {
    value = aws_vpc.my-vpc
}

output "public_subnets" {
    value = aws_subnet.public-subnets[*].id
}

output "private_subnets" {
    value = aws_subnet.private-subnets[*].id
}
