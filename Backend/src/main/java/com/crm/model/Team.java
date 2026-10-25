package com.crm.model;

import java.sql.Timestamp;

public class Team {

    private int id;
    private String name;
    private String description;
    private Integer parentTeamId;
    private String parentTeamName;
    private Integer leaderId;
    private String leaderName;
    private String region;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Team() {
    }

    public Team(int id, String name, String description) {
        this.id = id;
        this.name = name;
        this.description = description;
    }

    public Team(int id, String name, String description, Integer parentTeamId, Integer leaderId, String region) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.parentTeamId = parentTeamId;
        this.leaderId = leaderId;
        this.region = region;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getTeamId() {
        return id;
    }

    public void setTeamId(int teamId) {
        this.id = teamId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getTeamName() {
        return name;
    }

    public void setTeamName(String teamName) {
        this.name = teamName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Integer getParentTeamId() {
        return parentTeamId;
    }

    public void setParentTeamId(Integer parentTeamId) {
        this.parentTeamId = parentTeamId;
    }

    public String getParentTeamName() {
        return parentTeamName;
    }

    public void setParentTeamName(String parentTeamName) {
        this.parentTeamName = parentTeamName;
    }

    public Integer getLeaderId() {
        return leaderId;
    }

    public void setLeaderId(Integer leaderId) {
        this.leaderId = leaderId;
    }

    public String getLeaderName() {
        return leaderName;
    }

    public void setLeaderName(String leaderName) {
        this.leaderName = leaderName;
    }

    public String getRegion() {
        return region;
    }

    public void setRegion(String region) {
        this.region = region;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}