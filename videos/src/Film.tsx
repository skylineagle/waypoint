import { AbsoluteFill, Audio, staticFile } from "remotion";
import { useState, type FC } from "react";
import { fontFaceCss, holdUntilFontsLoad } from "./fonts";
import { scenes } from "./cues";
import { CostsScene } from "./scenes/CostsScene";
import { DayNightScene } from "./scenes/DayNightScene";
import { FinaleScene } from "./scenes/FinaleScene";
import { LiveScene } from "./scenes/LiveScene";
import { OnboardingScene } from "./scenes/OnboardingScene";
import { OpeningScene } from "./scenes/OpeningScene";
import { TodayScene } from "./scenes/TodayScene";
import { WidgetsScene } from "./scenes/WidgetsScene";
import { World } from "./world/World";

export type FilmProps = { withAudio?: boolean };

export const Film: FC<FilmProps> = ({ withAudio = true }) => {
  useState(holdUntilFontsLoad);
  return (
    <AbsoluteFill style={{ backgroundColor: "#070c1a" }}>
      <style>{fontFaceCss}</style>
      <World />
      <OpeningScene window={scenes.opening} />
      <OnboardingScene window={scenes.onboarding} />
      <TodayScene window={scenes.today} />
      <LiveScene window={scenes.live} />
      <WidgetsScene window={scenes.widgets} />
      <CostsScene window={scenes.costs} />
      <DayNightScene window={scenes.dayNight} />
      <FinaleScene window={scenes.finale} />
      {withAudio && <Audio src={staticFile("audio/soundtrack.wav")} />}
    </AbsoluteFill>
  );
};
