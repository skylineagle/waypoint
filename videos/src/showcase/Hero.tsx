import { AbsoluteFill } from "remotion";
import { useState, type FC } from "react";
import { fontFaceCss, holdUntilFontsLoad } from "../fonts";
import { colors, fonts } from "../theme";
import { AppIcon } from "../ui/AppIcon";
import { Wordmark } from "../ui/Wordmark";
import { Backdrop } from "./Backdrop";
import { FlatPhone } from "./FlatPhone";

const SIDE_PHONES = [
  { name: "receipt-filled", left: 870 },
  { name: "journey-share", left: 1290 },
];

export const Hero: FC = () => {
  useState(holdUntilFontsLoad);
  return (
    <AbsoluteFill style={{ fontFamily: fonts.body, color: "#fff" }}>
      <style>{fontFaceCss}</style>
      <Backdrop />
      {SIDE_PHONES.map((phone) => (
        <div key={phone.name} style={{ position: "absolute", left: phone.left, top: 190, opacity: 0.9 }}>
          <FlatPhone width={290} screens={[{ name: phone.name, at: 0 }]} />
        </div>
      ))}
      <div style={{ position: "absolute", left: 1055, top: 95 }}>
        <FlatPhone width={330} screens={[{ name: "today-japan", at: 0 }]} />
      </div>
      <div style={{ position: "absolute", left: 110, top: 0, bottom: 0, width: 680, display: "flex", flexDirection: "column", justifyContent: "center" }}>
        <AppIcon size={150} />
        <div style={{ marginTop: 36 }}>
          <Wordmark at={-10} size={124} />
        </div>
        <div style={{ marginTop: 22, fontSize: 50, fontWeight: 700, letterSpacing: -1.5, lineHeight: 1.12 }}>Your trip, stop by stop.</div>
        <div style={{ marginTop: 22, fontSize: 27, color: colors.soft, lineHeight: 1.5 }}>Today&apos;s plan, Live Activities, widgets, receipt scanning and photo journeys.</div>
        <div style={{ marginTop: 26, fontSize: 22, color: colors.muted }}>The iPhone companion for your self-hosted TREK.</div>
      </div>
    </AbsoluteFill>
  );
};
