
# provider: OpenStack
terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

# VM flavor
data "openstack_compute_flavor_v2" "myflavor" {
  vcpus = 8
  ram   = 16384 # 16GB = 16 x 1024
}

# VM image
data "openstack_images_image_v2" "myimage" {
  # need to look this up manually
  name        = "Image for EGI Ubuntu 20.04 [Ubuntu/20.04/VirtualBox]"
  most_recent = true
}

# Security Groups
resource "openstack_compute_secgroup_v2" "ssh" {
  name        = "ssh"
  description = "ssh access"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

# Public SSH key
resource "openstack_compute_keypair_v2" "mykey" {
  name       = "mykey"
  # replace this with your public SSH key
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6NRGgoa77is6YJGo7xJP1awgMjTDC3b39vEfdTDuN85I8YAGluctwxZjCXTuCFJT6XpnD+8k6NFJytzbcX8ZsIwrFJEwW+xexbaYESnlDfYfF+tSyozMJFGCUzt9BC8tpPbK50gKNJ70rlx6I3biXA1JhhFOwVq661ISwID/akNqHb1lX4T4c9xGJKSm/GpN16KH43BtgXpdznQoVJIp/5cwWqJfmpSe2yVBZqJ3eISFlXXbMwuys8MEvyY0xQRvRIB5P+ACjRQyqrnGGP8rYwtVuvPkUrzrKuLK5J1p0xm4t5aYNGrKyL3WQkk1V4qNN+Acb/yQCyVeInJSE+4fF /home/sebastian/.ssh/id_rsa"
}

# VM
resource "openstack_compute_instance_v2" "myvm" {
  name            = "Test VM"
  image_id        = data.openstack_images_image_v2.myimage.id
  flavor_id       = data.openstack_compute_flavor_v2.myflavor.id
  key_pair        = openstack_compute_keypair_v2.mykey.name
  security_groups = ["ssh"]
  network {
    # need to look this up manually
    name = "group-project-network"
  }
}

# create floating IP
resource "openstack_networking_floatingip_v2" "myvm_fip" {
  # need to look this up manually
  pool = "public-muni-147-251-21-GROUP"
}

# associate floating IP
resource "openstack_compute_floatingip_associate_v2" "associate_myvm_fip" {
  floating_ip = openstack_networking_floatingip_v2.myvm_fip.address
  instance_id = openstack_compute_instance_v2.myvm.id
}

# print out the floating IP to connect to
output "public_ip" {
  value = openstack_networking_floatingip_v2.myvm_fip.address
}
