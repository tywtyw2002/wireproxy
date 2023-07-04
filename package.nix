{ lib
, buildGoModule
,
}:
buildGoModule rec {
  pname = "wireproxy";
  version = "1.0.5-dev";

  src = lib.cleanSource ./src;

  vendorSha256 = "sha256-JSRKp99duO0RnBdj3IKBTqAzvBVrYLmOqxmHGHbcldo=";

  meta = with lib; {
    description = "A wireguard client that exposes itself as a socks5/http proxy or tunnels.(mod)";
    homepage = "https://github.com/pufferffish/wireproxy";
    license = licenses.mit;
  };
}
