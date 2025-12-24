package com.example.AuctionApplication.entity;

import jakarta.persistence.*;

@Entity
@Table(name ="users")
public class Userdum {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
}
