{...}:
{
    imports = builtins.filter (name: name != "default.nix") (builtins.attrNames (builtins.readDir ./.) ); 
}