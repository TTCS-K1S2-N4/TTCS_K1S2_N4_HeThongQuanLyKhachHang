package com.qlkh.repository;

import com.qlkh.entity.Team;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TeamRepository extends JpaRepository<Team, Long> {
    List<Team> findByParentId(Long parentId);
}
