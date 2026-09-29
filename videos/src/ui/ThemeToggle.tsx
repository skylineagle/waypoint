import type { FC } from "react";
import { easeInOut, progress } from "../motion";
import { colors, fonts } from "../theme";
import { useTime } from "../useTime";

export type ThemeToggleProps = { switchAt: number };

const KNOB = 196;

export const ThemeToggle: FC<ThemeToggleProps> = ({ switchAt }) => {
  const time = useTime();
  const knob = progress(time, switchAt - 0.25, 0.25, easeInOut);
  const label = (text: string, activeWhenDark: boolean) => {
    const selected = activeWhenDark ? knob > 0.5 : knob <= 0.5;
    return (
      <div style={{ width: KNOB, textAlign: "center", position: "relative", zIndex: 1, fontFamily: fonts.body, fontWeight: 600, fontSize: 34, color: selected ? colors.ink : "#fff" }}>
        {text}
      </div>
    );
  };
  return (
    <div
      style={{
        position: "relative",
        display: "flex",
        padding: 10,
        borderRadius: 999,
        backgroundColor: knob > 0.5 ? colors.card : "rgba(17,24,39,0.9)",
        boxShadow: `0 40px 90px rgba(0,0,0,0.4), 0 0 0 2px ${colors.ring}`,
      }}
    >
      <div style={{ position: "absolute", top: 10, bottom: 10, left: 10, width: KNOB, borderRadius: 999, backgroundColor: "#fff", transform: `translateX(${knob * KNOB}px)` }} />
      <div style={{ display: "flex", padding: "12px 0" }}>
        {label("Light", false)}
        {label("Dark", true)}
      </div>
    </div>
  );
};
