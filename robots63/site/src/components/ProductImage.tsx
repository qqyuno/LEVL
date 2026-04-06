"use client";

import Image from "next/image";
import { useState } from "react";

interface Props {
  src: string;
  alt: string;
  style?: React.CSSProperties;
}

export default function ProductImage({ src, alt, style }: Props) {
  const [error, setError] = useState(false);

  if (error) return null;

  return (
    <Image
      src={src}
      alt={alt}
      fill
      priority
      sizes="(max-width: 900px) 100vw, 50vw"
      style={{ objectFit: "contain", padding: 24, ...style }}
      onError={() => setError(true)}
    />
  );
}
