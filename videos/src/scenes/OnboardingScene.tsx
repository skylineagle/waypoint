import { OffthreadVideo, Sequence, staticFile, useVideoConfig } from "remotion";
import type { FC } from "react";
import type { SceneWindow } from "../cues";
import { Checklist } from "../ui/Checklist";
import { Headline } from "../ui/Headline";
import { PhoneFrame } from "../ui/PhoneFrame";
import { Placed } from "../ui/Placed";
import { ScreenImage } from "../ui/ScreenImage";
import { ENTER_LEAD, Shot } from "../ui/Shot";
import { Stage } from "../ui/Stage";

export type OnboardingSceneProps = { window: SceneWindow };

const CLIP_SECONDS = 6;
const STEP_TIMES = { server: 0.4, signIn: 1.41, trip: 3.66, shortcut: 4.18, done: 5.1 };

export const OnboardingScene: FC<OnboardingSceneProps> = ({ window }) => {
  const { fps } = useVideoConfig();
  const clipStart = window.start - ENTER_LEAD;
  const at = (offset: number) => clipStart + offset;
  return (
    <Shot window={window}>
      <Stage window={window} orbitFrom={-9} orbitTo={7}>
        <Placed x={200} y={180}>
          <PhoneFrame width={500}>
            <div style={{ position: "absolute", inset: 0, transform: "scale(1.065)", transformOrigin: "50% 0%" }}>
              <ScreenImage name="onboarding-last" />
              <Sequence from={Math.round(clipStart * fps)} durationInFrames={Math.round(CLIP_SECONDS * fps)} layout="none">
                <OffthreadVideo src={staticFile("raw/onboarding.mp4")} muted style={{ position: "absolute", inset: 0, width: "100%", height: "100%" }} />
              </Sequence>
            </div>
          </PhoneFrame>
        </Placed>
        <Placed x={-292} y={180} z={90}>
          <Checklist
            steps={[
              { label: "Connect your server", at: at(STEP_TIMES.server) },
              { label: "Sign in", at: at(STEP_TIMES.signIn) },
              { label: "Pick your trip", at: at(STEP_TIMES.trip) },
              { label: "Add Wallet shortcut", at: at(STEP_TIMES.shortcut) },
            ]}
            finishedAt={at(STEP_TIMES.done)}
          />
        </Placed>
      </Stage>
      <Headline eyebrow="get started" line="Your server." accent="Your trips." at={window.start + 0.1} />
    </Shot>
  );
};
