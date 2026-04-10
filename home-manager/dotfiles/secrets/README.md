# Secrets Management (agenix)

## Important

Always run `agenix` from this directory:

```bash
cd ~/.nix/home-manager/dotfiles/secrets
```

## Edit a secret

```bash
cd ~/.nix/home-manager/dotfiles/secrets
agenix -e secrets.d/<name>.age
```

Available secrets:

```bash
agenix -e secrets.d/zsh.age
agenix -e secrets.d/zsh-keys.age
agenix -e secrets.d/secret.age
agenix -e secrets.d/git-credentials.age
```

Decrypts with `~/.ssh/id_ed25519`, opens `$EDITOR`, then re-encrypts on save.

## Re-key all secrets (after changing public keys in secrets.nix)

```bash
agenix -r
```

## Add a new secret

1. Add entry in `secrets.nix`:

   ```nix
   "secrets.d/new-secret.age".publicKeys = users;
   ```

2. Create the encrypted file:

   ```bash
   agenix -e secrets.d/new-secret.age
   ```

3. Reference it in `default.nix`:

   ```nix
   age.secrets."new-secret".file = ./secrets.d/new-secret.age;
   ```

## Files

| File | Description |
|------|-------------|
| `secrets.nix` | Defines which public keys can decrypt each secret |
| `default.nix` | Declares secrets and where they get decrypted to |
| `secrets.d/*.age` | Encrypted secret files |

## Identity

Decryption uses: `~/.ssh/id_ed25519`

Authorized keys (from `secrets.nix`):
- `macmini` (ssh-ed25519)
- `nixos` (ssh-ed25519)
