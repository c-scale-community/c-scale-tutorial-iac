
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
  ram   = 16384
}

# VM image
data "openstack_images_image_v2" "myimage" {
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

# VM
resource "openstack_compute_instance_v2" "myvm" {
  name            = "Test VM"
  image_id        = data.openstack_images_image_v2.myimage.id
  flavor_id       = data.openstack_compute_flavor_v2.myflavor.id
  security_groups = ["ssh"]
  network {
    # need to look this up manually
    name = "group-project-network"
  }
}

