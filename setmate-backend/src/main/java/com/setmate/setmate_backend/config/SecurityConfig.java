package com.setmate.setmate_backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http.csrf(csrf -> csrf.disable()) // 禁用 CSRF（仅用于开发环境）
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/api/**").permitAll() // 放行 API 请求
                        .anyRequest().authenticated() // 其他请求需要认证
                );

        return http.build();
    }


}
