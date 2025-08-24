{ distro, ... }:
let 
  modules = if distro == "macos" then [./macos]
    else if distro == "nixos" then [./nixos]
    else if distro == "ubuntu" then [./ubuntu]
    else [];
in 
{
  imports = modules;
}