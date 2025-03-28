
#% terraform import aws_route.rfc1918 rtb-04206bbccd8a7252d_10.0.0.0/8
resource "aws_route" "rfc1918" {
  route_table_id         = aws_route_table.hub-rt-internal-prod-vpc-inspection.id
  destination_cidr_block = "10.0.0.0/8"
  network_interface_id   = "eni-048ec197c69832ce5"
}

#% terraform import aws_route.ztna-sp rtb-04206bbccd8a7252d_10.27.7.0/24
resource "aws_route" "ztna-sp" {
  route_table_id         = aws_route_table.hub-rt-internal-prod-vpc-inspection.id
  destination_cidr_block = "10.27.7.0/24"
  transit_gateway_id     = "tgw-0b729d487e581b734"
}

#% terraform import aws_route.pod-k8s-eventos rtb-04206bbccd8a7252d_10.37.128.0/17
resource "aws_route" "pod-k8s-eventos" {
  route_table_id         = aws_route_table.hub-rt-internal-prod-vpc-inspection.id
  destination_cidr_block = "10.37.128.0/17"
  transit_gateway_id     = "tgw-0b729d487e581b734"
}
#ruta de prueba para asociar a tabla
resource "aws_route" "privado" {
  route_table_id         = aws_route_table.hub-rt-internal-prod-vpc-inspection.id
  destination_cidr_block = "192.168.1.0/24"
  transit_gateway_id     = "tgw-0b729d487e581b734"
}