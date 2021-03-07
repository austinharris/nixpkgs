{ lib, fetchzip }:

let
  version = "2.038";
in fetchzip {
  name = "source-code-pro-${version}";

  url = "https://github.com/adobe-fonts/source-code-pro/archive/2.038R-ro/1.058R-it/1.018R-VAR.zip";

  postFetch = ''
    mkdir -p $out/share/fonts
    unzip -j $downloadedFile \*.otf -d $out/share/fonts/opentype
  '';

  sha256 = "3qhIiCWWJ8XYPA+0z1bXPDXR93VNgyZnNtHl+VHmSgs=";

  meta = {
    description = "A set of monospaced OpenType fonts designed for coding environments";
    maintainers = with lib.maintainers; [ relrod ];
    platforms = with lib.platforms; all;
    homepage = "https://adobe-fonts.github.io/source-code-pro/";
    license = lib.licenses.ofl;
  };
}
