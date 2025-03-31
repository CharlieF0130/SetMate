package com.setmate.setmate_backend.service;

import com.setmate.setmate_backend.model.User;
import com.setmate.setmate_backend.repository.UserRepository;
import com.setmate.setmate_backend.util.JwtUtil;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.jdbc.core.JdbcTemplate;

import java.util.Optional;

@Service
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final JdbcTemplate jdbcTemplate;

    public UserServiceImpl(UserRepository userRepository,
                           PasswordEncoder passwordEncoder,
                           JwtUtil jwtUtil,
                           JdbcTemplate jdbcTemplate) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
        this.jdbcTemplate = jdbcTemplate;
    }
    /**
     * Handles user registration.
     * <p>
     * Database Access Method: Prepared Statement (via JdbcTemplate)
     * <p>
     * Logic:
     * - Use JdbcTemplate.queryForObject(...) to check for duplicate email and username.
     * - Use JdbcTemplate.update(...) to insert the new user (after encoding password).
     * <p>
     * Security:
     * - Prevents SQL injection by using bound parameters (?).
     */
    @Override
    public String register(User user) {
        // 检查 email 和 username 是否已存在
        String emailSql = "SELECT COUNT(*) FROM users WHERE email = ?";
        String usernameSql = "SELECT COUNT(*) FROM users WHERE username = ?";

        Integer emailCount = jdbcTemplate.queryForObject(emailSql, Integer.class, user.getEmail());
        Integer usernameCount = jdbcTemplate.queryForObject(usernameSql, Integer.class, user.getUsername());

        if (emailCount != null && emailCount > 0) {
            throw new RuntimeException("Email has been registered");
        }
        if (usernameCount != null && usernameCount > 0) {
            throw new RuntimeException("Username already exists");
        }

        // 插入用户
        String insertSql = "INSERT INTO users (username, email, password) VALUES (?, ?, ?)";
        String encodedPassword = passwordEncoder.encode(user.getPassword());

        jdbcTemplate.update(insertSql, user.getUsername(), user.getEmail(), encodedPassword);

        return "Successful registration";
    }

    /**
     * Handles user login and JWT token generation.
     * <p>
     * Database Access Method: Prepared Statement (via JdbcTemplate)
     * <p>
     * Logic:
     * - Use JdbcTemplate.query(...) with a lambda to retrieve user by email.
     * - Match password with stored hash using PasswordEncoder.
     * - Generate JWT token if login is successful.
     * <p>
     * Security:
     * - Uses parameterized SQL to prevent SQL injection.
     */
    @Override
    public String login(User loginRequest) {
        String sql = "SELECT * FROM users WHERE email = ?";

        // 打印调试用
        System.out.println("Executing SQL: " + sql);
        System.out.println("Email: " + loginRequest.getEmail());

        User user = jdbcTemplate.query(sql, rs -> {
            if (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id")); // ✅ 修正字段名
                u.setUsername(rs.getString("username"));
                u.setEmail(rs.getString("email"));
                u.setPassword(rs.getString("password"));
                return u;
            }
            return null;
        }, loginRequest.getEmail());

        if (user == null) {
            throw new RuntimeException("Account does not exist");
        }

        if (!passwordEncoder.matches(loginRequest.getPassword(), user.getPassword())) {
            throw new RuntimeException("Wrong password");
        }

        UserDetails userDetails = org.springframework.security.core.userdetails.User
                .withUsername(user.getUsername())
                .password(user.getPassword())
                .authorities("USER")
                .build();

        return jwtUtil.generateToken(userDetails);
    }

    /**
     * Find user by username using JPA / ORM.
     * This method is used to retrieve userId from authenticated username in JWT.
     */
    @Override
    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }


}
