{ ibus-bamboo, system, ... }:

let
  bamboo = ibus-bamboo.packages."${system}".default;
in
{
  home.packages = [ bamboo];
}
