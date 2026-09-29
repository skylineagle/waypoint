import { AbsoluteFill } from "remotion";
import type { FC } from "react";
import { colors } from "../theme";
import { DotGrid } from "./DotGrid";
import { Glows } from "./Glows";
import { Route } from "./Route";
import { Starfield } from "./Starfield";

export const World: FC = () => (
  <AbsoluteFill style={{ backgroundColor: colors.night, overflow: "hidden" }}>
    <Glows />
    <DotGrid />
    <Starfield />
    <Route />
    <AbsoluteFill style={{ background: `linear-gradient(180deg, transparent 55%, rgba(7,12,26,0.55) 100%)` }} />
  </AbsoluteFill>
);
