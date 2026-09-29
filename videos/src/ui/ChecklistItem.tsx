import type { FC } from "react";
import { progress } from "../motion";
import { colors, fonts } from "../theme";
import { useTime } from "../useTime";

export type ChecklistItemProps = { label: string; activeAt: number; doneAt: number };

export const ChecklistItem: FC<ChecklistItemProps> = ({ label, activeAt, doneAt }) => {
  const time = useTime();
  const active = progress(time, activeAt, 0.3);
  const done = progress(time, doneAt, 0.3);
  const pulse = time >= activeAt && time < doneAt ? 0.5 + 0.5 * Math.sin((time - activeAt) * 7) : 0;
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 18, padding: "18px 0", opacity: 0.4 + 0.6 * active }}>
      <div
        style={{
          position: "relative",
          width: 46,
          height: 46,
          borderRadius: "50%",
          flexShrink: 0,
          border: `3px solid ${done > 0 ? colors.green : active > 0 ? "#fff" : "rgba(255,255,255,0.35)"}`,
          backgroundColor: `rgba(34,197,94,${done})`,
          boxShadow: `0 0 ${24 * pulse}px rgba(165,180,252,${0.8 * pulse})`,
        }}
      >
        <svg viewBox="0 0 24 24" width={30} height={30} style={{ position: "absolute", left: 5, top: 5 }}>
          <path
            d="M5 12.5l4.5 4.5L19 7.5"
            fill="none"
            stroke="#fff"
            strokeWidth={3}
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeDasharray={24}
            strokeDashoffset={24 * (1 - done)}
          />
        </svg>
      </div>
      <div style={{ fontFamily: fonts.body, fontWeight: 600, fontSize: 29, color: "#fff" }}>{label}</div>
    </div>
  );
};
