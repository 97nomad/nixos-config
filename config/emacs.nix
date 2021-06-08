rec {
  enable = true;
  extraPackages = epkgs: with epkgs; [
    ## Themes
    dracula-theme

    ## System and generic packages
    use-package company rainbow-delimiters
    ivy counsel swiper counsel-tramp
    lsp-mode lsp-ui lsp-ivy direnv

    ## Git
    magit

    ## File management
    dired-subtree neotree

    ## Nix
    nix-mode nixos-options company-nixos-options

    ## Elixir
    elixir-mode

    ## Rust
    rust-mode

    ## Modes
    yaml-mode dockerfile-mode docker-compose-mode k8s-mode
  ];
}
