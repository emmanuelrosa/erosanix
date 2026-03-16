{ pkgs
, libupdate
}:
libupdate.mkUpdateScript {
  comparator = "version";
  derivation = builtins.toPath ../pkgs/tiny_audio_player/default.nix;

  getRemoteVersion = libupdate.getRemoteVersionFromGitHub { 
    owner = "emmanuelrosa";
    repo = "tiny_audio_player";
    versionConverter = "${pkgs.gnused}/bin/sed 's/v//'";
  };

  getRemoteHash = libupdate.prefetchUrl "https://github.com/emmanuelrosa/tiny_audio_player/releases/download/v$version/tiny-audio-player_$version-1_amd64.deb";

}
