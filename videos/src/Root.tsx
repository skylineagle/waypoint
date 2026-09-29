import { Composition } from "remotion";
import type { FC } from "react";
import { Film } from "./Film";
import { FILM_SECONDS, FPS, HEIGHT, WIDTH } from "./theme";

export const Root: FC = () => (
  <Composition id="Promo" component={Film} durationInFrames={Math.round(FILM_SECONDS * FPS)} fps={FPS} width={WIDTH} height={HEIGHT} />
);
