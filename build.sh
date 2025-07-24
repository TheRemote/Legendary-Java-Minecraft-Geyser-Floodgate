docker buildx build --provenance=true --sbom=true --push -t 05jchambers/legendary-minecraft-geyser-floodgate:amd64 -f amd64.Dockerfile .
docker buildx build --provenance=true --sbom=true --push -t 05jchambers/legendary-minecraft-geyser-floodgate:arm64v8 -f arm64v8.Dockerfile .
docker buildx build --provenance=true --sbom=true --push -t 05jchambers/legendary-minecraft-geyser-floodgate:armv7 -f armv7.Dockerfile .
docker buildx build --provenance=true --sbom=true --push -t 05jchambers/legendary-minecraft-geyser-floodgate:ppc64le -f ppc64le.Dockerfile .
docker buildx build --provenance=true --sbom=true --push -t 05jchambers/legendary-minecraft-geyser-floodgate:s390x -f s390x.Dockerfile .

./manifest-tool-linux-amd64 push from-spec multi-arch-manifest.yaml