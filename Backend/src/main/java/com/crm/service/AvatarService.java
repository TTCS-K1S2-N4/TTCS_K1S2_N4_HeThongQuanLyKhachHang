package com.crm.service;

import com.crm.util.AvatarUtil;

import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.Map;

public class AvatarService {

    private final AvatarUtil avatarUtil;

    public AvatarService() {
        this.avatarUtil = new AvatarUtil();
    }

    public static String getPersistentUploadDir() {
        String userHome = System.getProperty("user.home");
        File dir = new File(userHome, "crm_uploads" + File.separator + "avatars");
        if (!dir.exists()) {
            dir.mkdirs();
        }
        return dir.getAbsolutePath();
    }

    public Map<String, String> uploadAvatar(int userId, InputStream inputStream, String fileName, String uploadRealPath, String contextPath) throws Exception {
        String persistentPath = getPersistentUploadDir();
        File persistentDir = new File(persistentPath);
        if (!persistentDir.exists()) {
            persistentDir.mkdirs();
        }

        String extension = "png";
        if (fileName != null && (fileName.toLowerCase().endsWith(".jpg") || fileName.toLowerCase().endsWith(".jpeg"))) {
            extension = "jpg";
        }

        String avatarFileName = "avatar_" + userId + "_" + System.currentTimeMillis() + "." + extension;
        String thumbFileName = "thumb_" + avatarFileName;

        File avatarFile = new File(persistentDir, avatarFileName);
        File thumbFile = new File(persistentDir, thumbFileName);

        // Process and save square image + thumbnail to persistent directory
        avatarUtil.processAndSaveSquareImage(inputStream, avatarFile, thumbFile, extension);

        // Also copy to uploadRealPath (exploded WAR) if valid
        if (uploadRealPath != null && !uploadRealPath.trim().isEmpty()) {
            File warUploadDir = new File(uploadRealPath);
            if (!warUploadDir.exists()) {
                warUploadDir.mkdirs();
            }
            File warAvatarFile = new File(warUploadDir, avatarFileName);
            File warThumbFile = new File(warUploadDir, thumbFileName);

            try {
                Files.copy(avatarFile.toPath(), warAvatarFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                Files.copy(thumbFile.toPath(), warThumbFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
            } catch (Exception ignored) {
                // Ignore if exploded WAR path is not writable or transient
            }
        }

        String baseUrl = (contextPath != null ? contextPath : "") + "/uploads/avatars/";
        Map<String, String> result = new HashMap<>();
        result.put("avatarUrl", baseUrl + avatarFileName);
        result.put("thumbnailUrl", baseUrl + thumbFileName);

        return result;
    }
}