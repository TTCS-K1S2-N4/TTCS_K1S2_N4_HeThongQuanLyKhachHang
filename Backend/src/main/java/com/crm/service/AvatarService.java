package com.crm.service;

import com.crm.util.AvatarUtil;

import java.io.File;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

public class AvatarService {

    private final AvatarUtil avatarUtil;

    public AvatarService() {
        this.avatarUtil = new AvatarUtil();
    }

    public Map<String, String> uploadAvatar(int userId, InputStream inputStream, String fileName, String uploadRealPath, String contextPath) throws Exception {
        if (uploadRealPath == null || uploadRealPath.trim().isEmpty()) {
            uploadRealPath = System.getProperty("java.io.tmpdir") + File.separator + "uploads" + File.separator + "avatars";
        }

        File uploadDir = new File(uploadRealPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        String extension = "png";
        if (fileName != null && (fileName.toLowerCase().endsWith(".jpg") || fileName.toLowerCase().endsWith(".jpeg"))) {
            extension = "jpg";
        }

        String avatarFileName = "avatar_" + userId + "_" + System.currentTimeMillis() + "." + extension;
        String thumbFileName = "thumb_" + avatarFileName;

        File avatarFile = new File(uploadDir, avatarFileName);
        File thumbFile = new File(uploadDir, thumbFileName);

        avatarUtil.processAndSaveSquareImage(inputStream, avatarFile, thumbFile, extension);

        String baseUrl = (contextPath != null ? contextPath : "") + "/uploads/avatars/";
        Map<String, String> result = new HashMap<>();
        result.put("avatarUrl", baseUrl + avatarFileName);
        result.put("thumbnailUrl", baseUrl + thumbFileName);

        return result;
    }
}