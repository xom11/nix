{
    system = {
    # Turn off NIX_PATH warnings now that we're using flakes
    # checks.verifyNixPath = false;
    primaryUser = user;
    stateVersion = 6;
    defaults = {
      dock = {
        autohide = true;
      };

    };
  };
}