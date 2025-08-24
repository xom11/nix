{ ibus-bamboo, system, ... }:

let
  bamboo = ibus-bamboo.packages."${system}".default;
in
{
  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = [
      bamboo
    ];
  };
}
