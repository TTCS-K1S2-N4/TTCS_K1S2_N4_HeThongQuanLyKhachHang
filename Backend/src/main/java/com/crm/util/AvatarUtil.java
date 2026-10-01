package com.crm.util;

import javax.imageio.ImageIO;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.InputStream;

public class AvatarUtil {

    public void processAndSaveSquareImage(InputStream inputStream, File avatarOutputFile, File thumbOutputFile, String formatName) throws Exception {
        BufferedImage originalImage = ImageIO.read(inputStream);
        if (originalImage == null) {
            throw new IllegalArgumentException("Dữ liệu file không phải là ảnh hợp lệ.");
        }

        BufferedImage squareImage = cropToSquare(originalImage);
        BufferedImage thumbImage = resizeImage(squareImage, 150, 150);

        String writeFormat = ("jpg".equalsIgnoreCase(formatName) || "jpeg".equalsIgnoreCase(formatName)) ? "jpg" : "png";

        ImageIO.write(squareImage, writeFormat, avatarOutputFile);
        ImageIO.write(thumbImage, writeFormat, thumbOutputFile);
    }

    public BufferedImage cropToSquare(BufferedImage img) {
        int width = img.getWidth();
        int height = img.getHeight();

        int cropSize = Math.min(width, height);
        int x = (width - cropSize) / 2;
        int y = (height - cropSize) / 2;

        return img.getSubimage(x, y, cropSize, cropSize);
    }

    public BufferedImage resizeImage(BufferedImage originalImage, int targetWidth, int targetHeight) {
        int imageType = (originalImage.getType() == 0) ? BufferedImage.TYPE_INT_ARGB : originalImage.getType();
        BufferedImage resizedImage = new BufferedImage(targetWidth, targetHeight, imageType);
        Graphics2D g = resizedImage.createGraphics();

        g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        g.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);

        g.drawImage(originalImage, 0, 0, targetWidth, targetHeight, null);
        g.dispose();

        return resizedImage;
    }
}