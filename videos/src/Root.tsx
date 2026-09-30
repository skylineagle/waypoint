import { Composition, Still } from "remotion";
import type { FC } from "react";
import { Film } from "./Film";
import { FPS as SHOWCASE_FPS, HEIGHT as SHOWCASE_HEIGHT, SECONDS as SHOWCASE_SECONDS, WIDTH as SHOWCASE_WIDTH } from "./showcase/cues";
import { Hero } from "./showcase/Hero";
import { Showcase } from "./showcase/Showcase";
import { FILM_SECONDS, FPS, HEIGHT, WIDTH } from "./theme";

export const Root: FC = () => (
  <>
    <Composition id="Promo" component={Film} durationInFrames={Math.round(FILM_SECONDS * FPS)} fps={FPS} width={WIDTH} height={HEIGHT} />
    <Composition
      id="Showcase"
      component={Showcase}
      durationInFrames={Math.round(SHOWCASE_SECONDS * SHOWCASE_FPS)}
      fps={SHOWCASE_FPS}
      width={SHOWCASE_WIDTH}
      height={SHOWCASE_HEIGHT}
      defaultProps={{ withAudio: false }}
    />
    <Still id="Hero" component={Hero} width={1600} height={900} />
  </>
);
