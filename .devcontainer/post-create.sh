#!/bin/bash

echo "🚀 Setting up Java 21 Spring Boot development environment..."

# Wait for PostgreSQL to be ready
echo "⏳ Waiting for PostgreSQL to be ready..."
until pg_isready -h localhost -p 5432 -U postgres; do
  echo "PostgreSQL is not ready yet, waiting..."
  sleep 2
done

echo "✅ PostgreSQL is ready!"

# Create a sample Spring Boot project if it doesn't exist
if [ ! -f "pom.xml" ] && [ ! -f "build.gradle" ]; then
    echo "📦 Creating sample Spring Boot project..."
    
    cat > pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.1</version>
        <relativePath/>
    </parent>
    <groupId>com.example</groupId>
    <artifactId>demo</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>demo</name>
    <description>Demo project for Spring Boot</description>
    <properties>
        <java.version>21</java.version>
    </properties>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
EOF

    # Create application.properties
    mkdir -p src/main/resources
    cat > src/main/resources/application.properties << 'EOF'
# Database Configuration
spring.datasource.url=jdbc:postgresql://localhost:5432/springboot_db
spring.datasource.username=postgres
spring.datasource.password=postgres
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA Configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.properties.hibernate.format_sql=true

# Server Configuration
server.address=${SERVER_HOST:0.0.0.0}
server.port=${SERVER_PORT:8080}

# Logging
logging.level.org.springframework.web=DEBUG
logging.level.org.hibernate.SQL=DEBUG
EOF

    # Create sample Java files
    mkdir -p src/main/java/com/example/demo
    cat > src/main/java/com/example/demo/DemoApplication.java << 'EOF'
package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}
EOF

    # コントローラーの作成
    cat > src/main/java/com/example/demo/HomeController.java << 'EOF'
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
        response.put("message", "🎉 Spring Boot with Java 21 is running!");
        response.put("timestamp", java.time.LocalDateTime.now());
        response.put("java_version", System.getProperty("java.version"));
        response.put("spring_boot", "✅ Working");
        
        // データベース接続テスト
        try (Connection conn = dataSource.getConnection()) {
            response.put("database", "✅ PostgreSQL Connected");
            response.put("database_url", conn.getMetaData().getURL());
        } catch (Exception e) {
            response.put("database", "❌ Database Error: " + e.getMessage());
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
EOF

    # User エンティティの作成
    cat > src/main/java/com/example/demo/User.java << 'EOF'
package com.example.demo;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String username;
    
    @Column(unique = true, nullable = false)
    private String email;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    // Constructors
    public User() {}
    
    public User(String username, String email) {
        this.username = username;
        this.email = email;
        this.createdAt = LocalDateTime.now();
    }
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
EOF

    echo "✅ Sample Spring Boot project created!"
fi

# Install dependencies
if [ -f "pom.xml" ]; then
    echo "📥 Installing Maven dependencies..."
    mvn dependency:resolve
elif [ -f "build.gradle" ]; then
    echo "📥 Installing Gradle dependencies..."
    ./gradlew build --no-daemon
fi

echo "🎉 Development environment is ready!"
echo ""
echo "🔧 Available commands:"
echo "  mvn spring-boot:run    - Start the Spring Boot application"
echo "  mvn test              - Run tests"
echo "  mvn clean install     - Build the project"
echo ""
echo "🌐 Access points:"
echo "  Spring Boot App: http://${PUBLIC_HOST:-localhost}:${SERVER_PORT:-8080}"
echo "  PostgreSQL: ${PUBLIC_HOST:-localhost}:5432 (user: postgres, password: postgres)"
echo ""
echo "📝 Database connection test:"
psql -h localhost -U postgres -d springboot_db -c "SELECT 'Database connection successful!' as status;"

# .envファイルの作成案内
if [ ! -f ".env" ]; then
    echo ""
    echo "⚠️  .env file not found!"
    echo "📋 Please create .env file from template:"
    echo "   cp .env.template .env"
    echo "   # Edit .env file with your EC2 public IP address"
fi