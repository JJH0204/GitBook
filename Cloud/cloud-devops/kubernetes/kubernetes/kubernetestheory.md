# 쿠버네티스 핵심 이론 (Kubernetes)

{% hint style="warning" %}
{% endhint %}

Docker와 같이 컨테이너 기반(하지만 많이 다른) Tool

App이 실행되는 환경을 격리하는 기술

Container Run-time

오케스트레이션??: 여러 컨테이너를 관리할 수 있게 하는 기술

API(Docker-D)를 활용해 컨테이너 간 통신이 가능하게 함

K8s = Kubernets

단일: 하나의 node에 구축 멀티: 둘 이상의 node에 구축

중앙 통제 cluster 통제

컴퓨팅 노드와 연결됨

컨테이너(클러스트)간 상호 통신을 위해 필요

노드안의 컨테이너들이 사용하는 리소스양과 상태를 관리

인증을 위한 키, 데이터 저장

\= 노드

\= Unit(가장 단순한 구조)

모든 container 들은 Pod에 의해 관리된다.

ControlPlane과 통신을 담당

내부 네트워크 구성 (안정적으로 외부와 통신할 수 있도록)

컨테이너를 구동 하려면 이미지가 필요함 이미지가 등록되는 공간

각 컨테이너마다 고유한 저장소

Kube-Adm 외 다양한 툴이 있다.

Master Node

Worker Node

Worker Node

api

api

각각의 노드를 관리

Container Run-time

Container Run-time

Container Run-time

유연성(확장성): 언제든지 Node를 구축(삭제)하여 서비스를 유동적으로 관리할 수 있다.

DevOps 시스템에 핵심 기술 - AWS

EKS?

엘라스틱 서치 쿠버네티스 시큐리티

기능 확장으로 DevSecOps 환경에 사용된다.

Node

원래 ip + Proxy ip 로 외부와 통신 (브릿지로 연결된다.)

Kube-Proxy

Service

Pod

C

C

C

VM

(중요)node 끼리 통신도 proxy를 통해야 가능하다.
