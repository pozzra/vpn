import json
import os
from PIL import Image, ImageDraw, ImageFont

def create_vpn_icon(size):
    # Create base RGBA image
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Gradient background
    for y in range(size):
        r = int(10 + (22 - 10) * (y / size))
        g = int(14 + (30 - 14) * (y / size))
        b = int(24 + (50 - 24) * (y / size))
        draw.line([(0, y), (size, y)], fill=(r, g, b, 255))

    # Outer rounded rectangle mask
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    corner_radius = int(size * 0.22)
    mask_draw.rounded_rectangle([(0, 0), (size, size)], radius=corner_radius, fill=255)
    img.putalpha(mask)

    draw = ImageDraw.Draw(img)

    # Draw cyber glow circle
    cx, cy = size // 2, size // 2
    glow_radius = int(size * 0.38)
    draw.ellipse(
        [(cx - glow_radius, cy - glow_radius), (cx + glow_radius, cy + glow_radius)],
        outline=(0, 229, 255, 180),
        width=max(2, int(size * 0.025))
    )

    # Draw shield polygon
    shield_top = int(size * 0.22)
    shield_bottom = int(size * 0.76)
    shield_left = int(size * 0.25)
    shield_right = int(size * 0.75)
    shield_mid_y = int(size * 0.48)

    shield_pts = [
        (shield_left, shield_top),
        (shield_right, shield_top),
        (shield_right, shield_mid_y),
        (cx, shield_bottom),
        (shield_left, shield_mid_y)
    ]
    draw.polygon(shield_pts, fill=(18, 28, 48, 220), outline=(0, 240, 255, 255))

    # Draw lock body inside shield
    lock_w = int(size * 0.18)
    lock_h = int(size * 0.16)
    lock_left = cx - lock_w // 2
    lock_top = int(size * 0.42)
    draw.rounded_rectangle(
        [(lock_left, lock_top), (lock_left + lock_w, lock_top + lock_h)],
        radius=max(2, int(size * 0.03)),
        fill=(0, 229, 255, 255)
    )

    # Draw lock shackle
    shackle_r = int(size * 0.065)
    shackle_top = lock_top - shackle_r * 2 + int(size * 0.02)
    draw.arc(
        [(cx - shackle_r, shackle_top), (cx + shackle_r, shackle_top + shackle_r * 2)],
        start=180, end=0,
        fill=(0, 240, 255, 255),
        width=max(2, int(size * 0.025))
    )

    # Keyhole
    draw.ellipse(
        [(cx - int(size * 0.015), lock_top + int(size * 0.04)),
         (cx + int(size * 0.015), lock_top + int(size * 0.07))],
        fill=(10, 14, 23, 255)
    )

    # Draw brand text "RXAA"
    font_size = max(8, int(size * 0.08))
    try:
        font = ImageFont.truetype("arial.ttf", font_size)
    except:
        font = ImageFont.load_default()

    text = "RXAA"
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    draw.text((cx - tw // 2, int(size * 0.61)), text, fill=(0, 255, 128, 255), font=font)

    return img

# Generate Android mipmap icons
android_res = "android/app/src/main/res"
android_sizes = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

for folder, s in android_sizes.items():
    dir_path = os.path.join(android_res, folder)
    os.makedirs(dir_path, exist_ok=True)
    icon = create_vpn_icon(s)
    icon.save(os.path.join(dir_path, "ic_launcher.png"), "PNG")

# Generate iOS AppIcon set from Contents.json
ios_dir = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
with open(os.path.join(ios_dir, "Contents.json"), "r") as f:
    contents = json.load(f)

for item in contents["images"]:
    size_str = item["size"].split("x")[0]
    scale_str = item["scale"].replace("x", "")
    px = int(float(size_str) * float(scale_str))
    filename = item["filename"]
    icon = create_vpn_icon(px)
    icon.save(os.path.join(ios_dir, filename), "PNG")

# Generate Web icons
web_dir = "web/icons"
os.makedirs(web_dir, exist_ok=True)
create_vpn_icon(192).save(os.path.join(web_dir, "Icon-192.png"), "PNG")
create_vpn_icon(512).save(os.path.join(web_dir, "Icon-512.png"), "PNG")
create_vpn_icon(1024).save("ios/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png", "PNG")

print("All app icons generated successfully for Android, iOS, and Web!")

