let                                
   stable = import (builtins.fetchTarball {                                
      name = "nixos-20.09";                                
      url = "https://github.com/NixOS/nixpkgs/archive/20.09.tar.gz";                                
      sha256 = "1wg61h4gndm3vcprdcg7rc4s1v3jkm5xd7lw8r2f67w502y94gcy";                                
   }) {};                                

   voodoo = import (builtins.fetchGit {                                
     url = "git@github.com:VoodooTeam/nix-pkgs.git";                                
     rev = "93c824e52bf16630e08a0d6d43f728857471a93d";                                
   }) stable;

  in                                
  stable.mkShell {                                
    buildInputs =
       [ 
         voodoo.terraform_0_14_6
     ];                                
  }      


