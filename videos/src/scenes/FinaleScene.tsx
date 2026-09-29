import type { FC } from "react";
import type { SceneWindow } from "../cues";
import { beat } from "../cues";
import { springAt } from "../motion";
import { colors, fonts } from "../theme";
import { AppIcon } from "../ui/AppIcon";
import { Placed } from "../ui/Placed";
import { Shot } from "../ui/Shot";
import { Stage } from "../ui/Stage";
import { Words } from "../ui/Words";
import { Wordmark } from "../ui/Wordmark";
import { useTime } from "../useTime";

export type FinaleSceneProps = { window: SceneWindow };

export const FinaleScene: FC<FinaleSceneProps> = ({ window }) => {
  const time = useTime();
  const icon = springAt(time - window.start + 0.3, 13, 100);
  return (
    <Shot window={window} exits={false}>
      <Stage window={window} orbitFrom={7} orbitTo={-4} tilt={2}>
        <Placed y={-300} z={-600 * (1 - icon)} rotateY={-35 * (1 - icon)} scale={Math.max(0.001, icon)} opacity={Math.min(1, icon * 2)}>
          <AppIcon size={360} />
        </Placed>
        <Placed y={-10} z={40}>
          <Wordmark at={window.start + 0.25} size={180} />
        </Placed>
      </Stage>
      <div style={{ position: "absolute", left: 0, right: 0, top: 1130, textAlign: "center", fontFamily: fonts.body }}>
        <Words text="Your TREK companion." at={window.start + beat(2)} style={{ fontSize: 58, fontWeight: 600, color: colors.soft }} />
        <Words
          text="Itinerary, budget, and map. For the TREK server you run."
          at={window.start + beat(3)}
          stagger={0.04}
          style={{ marginTop: 26, fontSize: 36, color: colors.muted, whiteSpace: "normal", padding: "0 150px", lineHeight: 1.45 }}
        />
      </div>
    </Shot>
  );
};
