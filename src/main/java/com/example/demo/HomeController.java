package com.example.demo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import javax.sql.DataSource;
import java.sql.Connection;
import java.util.HashMap;
import java.util.Map;

@RestController
public class HomeController {
    
    @Autowired
    private DataSource dataSource;
    
    @GetMapping("/")
    public Map<String, Object> home() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Spring Boot with Java 21 is running!");
        response.put("timestamp", java.time.LocalDateTime.now());
        response.put("java_version", System.getProperty("java.version"));
        response.put("spring_boot", "Working");
        
        // データベース接続テスト
        try (Connection conn = dataSource.getConnection()) {
            response.put("database", "PostgreSQL Connected");
            response.put("database_url", conn.getMetaData().getURL());
        } catch (Exception e) {
            response.put("database", "Database Error: " + e.getMessage());
        }
        
        return response;
    }
    
    @GetMapping("/health")
    public Map<String, String> health() {
        Map<String, String> status = new HashMap<>();
        status.put("status", "UP");
        status.put("service", "Spring Boot Demo");
        return status;
    }
    
    @GetMapping("/api/users")
    public Map<String, Object> getUsers() {
        Map<String, Object> response = new HashMap<>();
        try (Connection conn = dataSource.getConnection()) {
            var stmt = conn.createStatement();
            var rs = stmt.executeQuery("SELECT COUNT(*) as user_count FROM users");
            if (rs.next()) {
                response.put("total_users", rs.getInt("user_count"));
            }
            response.put("message", "Users table accessed successfully");
        } catch (Exception e) {
            response.put("error", e.getMessage());
        }
        return response;
    }
}
