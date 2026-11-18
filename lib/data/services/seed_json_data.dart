// Generated from skku-crew-backend/src/main/resources/seed/*.json
library;

class SeedJsonData {
  const SeedJsonData._();

  static const String profilesJson = r'''
[
  {
    "memberId": 1,
    "majorPrimary": "소프트웨어학과",
    "majorsSecondary": [
      "통계학과"
    ],
    "academicStatus": "GRADE_3",
    "bio": "데이터로 문제를 푸는 개발자",
    "fields": [
      "DEV",
      "DATA",
      "AI"
    ],
    "skills": [
      {
        "id": 11,
        "name": "Python",
        "level": "HIGH"
      },
      {
        "id": 12,
        "name": "SQL",
        "level": "MID"
      },
      {
        "id": 13,
        "name": "Flutter",
        "level": "MID"
      },
      {
        "id": 14,
        "name": "Git",
        "level": "MID"
      }
    ],
    "experiences": [
      {
        "id": 21,
        "type": "PROJECT",
        "title": "교통 혼잡도 시각화 프로젝트",
        "role": "데이터 분석·시각화",
        "startDate": "2026-03-02",
        "endDate": "2026-06-20",
        "description": "서울시 교통량 공공데이터로 시간대별 혼잡도를 분석하고 지도 시각화를 만들었습니다."
      },
      {
        "id": 22,
        "type": "PROJECT",
        "title": "캠퍼스 중고거래 웹앱",
        "role": "백엔드 개발",
        "startDate": "2025-09-01",
        "endDate": "2025-12-15",
        "description": "Spring Boot와 MySQL로 거래 게시판·채팅 API를 구현했습니다."
      },
      {
        "id": 23,
        "type": "AWARD",
        "title": "교내 해커톤 장려상",
        "role": "팀장",
        "startDate": "2025-11-15",
        "endDate": "2025-11-16",
        "description": "공공 데이터를 활용한 캠퍼스 안내 서비스로 수상했습니다."
      }
    ],
    "portfolioLinks": [
      {
        "id": 31,
        "title": "GitHub",
        "url": "https://github.com/example-minjun"
      },
      {
        "id": 32,
        "title": "기술 블로그",
        "url": "https://example.com/blog/minjun"
      }
    ],
    "portfolioFiles": [
      {
        "id": 41,
        "fileName": "포트폴리오.pdf",
        "url": "https://example.com/files/portfolio_minjun.pdf"
      }
    ],
    "contacts": {
      "phone": null,
      "kakaoId": "minjun_k",
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": true,
      "personalEmail": false
    },
    "activityHistory": [
      {
        "applicationId": 505,
        "postingId": 103,
        "postingTitle": "데이터 분석 학회 D:LAB 27기 모집",
        "recruiterName": "데이터 분석 학회 D:LAB",
        "announcedAt": null,
        "visible": true
      }
    ]
  },
  {
    "memberId": 2,
    "majorPrimary": "소프트웨어학과",
    "majorsSecondary": [],
    "academicStatus": "GRADE_2",
    "bio": "데이터 시각화로 이야기를 전하고 싶은 개발자",
    "fields": [
      "DATA",
      "AI"
    ],
    "skills": [
      {
        "id": 51,
        "name": "Python",
        "level": "HIGH"
      },
      {
        "id": 52,
        "name": "SQL",
        "level": "MID"
      },
      {
        "id": 53,
        "name": "Tableau",
        "level": "MID"
      }
    ],
    "experiences": [
      {
        "id": 54,
        "type": "AWARD",
        "title": "학과 데이터 시각화 대회 장려상",
        "role": "시각화",
        "startDate": "2026-05-10",
        "endDate": "2026-05-24",
        "description": "대중교통 이용 데이터를 Tableau 대시보드로 정리했습니다."
      },
      {
        "id": 55,
        "type": "PROJECT",
        "title": "오픈소스 데이터 정제 스크립트 기여",
        "role": "컨트리뷰터",
        "startDate": "2026-07-01",
        "endDate": null,
        "description": "공공데이터 CSV 정제 도구에 결측치 처리 기능을 기여하고 있습니다."
      }
    ],
    "portfolioLinks": [
      {
        "id": 56,
        "title": "GitHub",
        "url": "https://github.com/example-seoyeon"
      }
    ],
    "portfolioFiles": [
      {
        "id": 57,
        "fileName": "포트폴리오.pdf",
        "url": "https://example.com/files/portfolio_seoyeon.pdf"
      }
    ],
    "contacts": {
      "phone": "010-2345-6789",
      "kakaoId": "seoyeon_data",
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": true,
      "phone": false,
      "kakaoId": true,
      "personalEmail": false
    },
    "activityHistory": [
      {
        "applicationId": 511,
        "postingId": 103,
        "postingTitle": "데이터 분석 학회 D:LAB 27기 모집",
        "recruiterName": "데이터 분석 학회 D:LAB",
        "announcedAt": null,
        "visible": true
      }
    ]
  },
  {
    "memberId": 3,
    "majorPrimary": "디자인학과",
    "majorsSecondary": [],
    "academicStatus": "GRADE_3",
    "bio": "사용자 경험을 고민하는 UX 디자이너",
    "fields": [
      "DESIGN",
      "PLANNING_MARKETING"
    ],
    "skills": [
      {
        "id": 61,
        "name": "Figma",
        "level": "HIGH"
      },
      {
        "id": 62,
        "name": "Illustrator",
        "level": "MID"
      },
      {
        "id": 63,
        "name": "Excel",
        "level": "LOW"
      }
    ],
    "experiences": [
      {
        "id": 64,
        "type": "PROJECT",
        "title": "학과 전시 웹사이트 디자인",
        "role": "UI 디자인",
        "startDate": "2026-04-01",
        "endDate": "2026-05-30",
        "description": "전시 안내 웹사이트의 화면을 설계했습니다."
      }
    ],
    "portfolioLinks": [
      {
        "id": 65,
        "title": "Behance",
        "url": "https://example.com/behance/yujin"
      }
    ],
    "portfolioFiles": [],
    "contacts": {
      "phone": "010-3456-7890",
      "kakaoId": "yujin_ux",
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": true,
      "personalEmail": false
    },
    "activityHistory": [
      {
        "applicationId": 512,
        "postingId": 103,
        "postingTitle": "데이터 분석 학회 D:LAB 27기 모집",
        "recruiterName": "데이터 분석 학회 D:LAB",
        "announcedAt": null,
        "visible": true
      }
    ]
  },
  {
    "memberId": 4,
    "majorPrimary": "통계학과",
    "majorsSecondary": [
      "경제학과"
    ],
    "academicStatus": "GRADE_4",
    "bio": "공모전 3회 참여, 데이터 분석 팀장",
    "fields": [
      "DATA",
      "FINANCE"
    ],
    "skills": [
      {
        "id": 71,
        "name": "Python",
        "level": "HIGH"
      },
      {
        "id": 72,
        "name": "SQL",
        "level": "HIGH"
      },
      {
        "id": 73,
        "name": "Tableau",
        "level": "MID"
      }
    ],
    "experiences": [],
    "portfolioLinks": [],
    "portfolioFiles": [],
    "contacts": {
      "phone": "010-4567-8901",
      "kakaoId": "jiho_stat",
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": false,
      "personalEmail": false
    },
    "activityHistory": []
  },
  {
    "memberId": 5,
    "majorPrimary": "경영학과",
    "majorsSecondary": [],
    "academicStatus": "GRADE_4",
    "bio": "금융 데이터와 전략 기획에 관심 많은 경영학도",
    "fields": [
      "FINANCE",
      "DATA"
    ],
    "skills": [
      {
        "id": 81,
        "name": "Excel",
        "level": "HIGH"
      },
      {
        "id": 82,
        "name": "Python",
        "level": "MID"
      }
    ],
    "experiences": [],
    "portfolioLinks": [],
    "portfolioFiles": [],
    "contacts": {
      "phone": null,
      "kakaoId": "haneul_fin",
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": false,
      "personalEmail": false
    },
    "activityHistory": []
  },
  {
    "memberId": 9,
    "majorPrimary": "소프트웨어학과",
    "majorsSecondary": [],
    "academicStatus": "GRADE_2",
    "bio": "알고리즘과 백엔드를 공부하는 중",
    "fields": [
      "DEV"
    ],
    "skills": [
      {
        "id": 91,
        "name": "Java",
        "level": "MID"
      },
      {
        "id": 92,
        "name": "C++",
        "level": "MID"
      }
    ],
    "experiences": [],
    "portfolioLinks": [
      {
        "id": 93,
        "title": "GitHub",
        "url": "https://github.com/example-doyun"
      }
    ],
    "portfolioFiles": [],
    "contacts": {
      "phone": "010-5678-9012",
      "kakaoId": null,
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": false,
      "personalEmail": false
    },
    "activityHistory": []
  },
  {
    "memberId": 10,
    "majorPrimary": "경영학과",
    "majorsSecondary": [],
    "academicStatus": "GRADE_3",
    "bio": "마케팅 기획과 콘텐츠 제작에 관심 있어요",
    "fields": [
      "PLANNING_MARKETING",
      "DESIGN"
    ],
    "skills": [
      {
        "id": 101,
        "name": "Premiere Pro",
        "level": "MID"
      },
      {
        "id": 102,
        "name": "Notion",
        "level": "HIGH"
      }
    ],
    "experiences": [],
    "portfolioLinks": [],
    "portfolioFiles": [],
    "contacts": {
      "phone": "010-6789-0123",
      "kakaoId": "seoa_mkt",
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": true,
      "personalEmail": false
    },
    "activityHistory": []
  },
  {
    "memberId": 11,
    "majorPrimary": "데이터사이언스융합전공",
    "majorsSecondary": [],
    "academicStatus": "GRADE_3",
    "bio": "데이터 파이프라인을 만드는 데이터 엔지니어 지망생",
    "fields": [
      "AI",
      "DATA"
    ],
    "skills": [
      {
        "id": 111,
        "name": "Python",
        "level": "HIGH"
      },
      {
        "id": 112,
        "name": "SQL",
        "level": "HIGH"
      },
      {
        "id": 113,
        "name": "Docker",
        "level": "MID"
      }
    ],
    "experiences": [],
    "portfolioLinks": [],
    "portfolioFiles": [],
    "contacts": {
      "phone": null,
      "kakaoId": "doyoon_de",
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": true,
      "personalEmail": false
    },
    "activityHistory": [
      {
        "applicationId": 514,
        "postingId": 103,
        "postingTitle": "데이터 분석 학회 D:LAB 27기 모집",
        "recruiterName": "데이터 분석 학회 D:LAB",
        "announcedAt": null,
        "visible": true
      }
    ]
  },
  {
    "memberId": 12,
    "majorPrimary": "통계학과",
    "majorsSecondary": [],
    "academicStatus": "GRADE_1",
    "bio": "통계학과에서 데이터 분석을 공부하고 있어요",
    "fields": [
      "DATA",
      "AI"
    ],
    "skills": [
      {
        "id": 201,
        "name": "Python",
        "level": "HIGH"
      },
      {
        "id": 202,
        "name": "R",
        "level": "MID"
      },
      {
        "id": 203,
        "name": "SQL",
        "level": "LOW"
      }
    ],
    "experiences": [],
    "portfolioLinks": [],
    "portfolioFiles": [],
    "contacts": {
      "phone": null,
      "kakaoId": "user12_k",
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": true,
      "personalEmail": false
    },
    "activityHistory": []
  },
  {
    "memberId": 13,
    "majorPrimary": "경영학과",
    "majorsSecondary": [],
    "academicStatus": "GRADE_2",
    "bio": "경영학과에서 데이터 분석을 공부하고 있어요",
    "fields": [
      "DATA",
      "FINANCE"
    ],
    "skills": [
      {
        "id": 204,
        "name": "Excel",
        "level": "MID"
      },
      {
        "id": 205,
        "name": "SQL",
        "level": "LOW"
      },
      {
        "id": 206,
        "name": "Tableau",
        "level": "HIGH"
      }
    ],
    "experiences": [],
    "portfolioLinks": [],
    "portfolioFiles": [],
    "contacts": {
      "phone": null,
      "kakaoId": "user13_k",
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": true,
      "personalEmail": false
    },
    "activityHistory": [
      {
        "applicationId": 516,
        "postingId": 103,
        "postingTitle": "데이터 분석 학회 D:LAB 27기 모집",
        "recruiterName": "데이터 분석 학회 D:LAB",
        "announcedAt": null,
        "visible": true
      }
    ]
  },
  {
    "memberId": 14,
    "majorPrimary": "소프트웨어학과",
    "majorsSecondary": [],
    "academicStatus": "GRADE_2",
    "bio": "소프트웨어학과에서 데이터 분석을 공부하고 있어요",
    "fields": [
      "DEV",
      "AI"
    ],
    "skills": [
      {
        "id": 207,
        "name": "Python",
        "level": "LOW"
      },
      {
        "id": 208,
        "name": "Java",
        "level": "HIGH"
      },
      {
        "id": 209,
        "name": "PyTorch",
        "level": "MID"
      }
    ],
    "experiences": [],
    "portfolioLinks": [],
    "portfolioFiles": [],
    "contacts": {
      "phone": null,
      "kakaoId": null,
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": false,
      "personalEmail": false
    },
    "activityHistory": [
      {
        "applicationId": 517,
        "postingId": 103,
        "postingTitle": "데이터 분석 학회 D:LAB 27기 모집",
        "recruiterName": "데이터 분석 학회 D:LAB",
        "announcedAt": null,
        "visible": true
      }
    ]
  },
  {
    "memberId": 15,
    "majorPrimary": "경제학과",
    "majorsSecondary": [],
    "academicStatus": "GRADE_3",
    "bio": "경제학과에서 데이터 분석을 공부하고 있어요",
    "fields": [
      "FINANCE",
      "DATA"
    ],
    "skills": [
      {
        "id": 210,
        "name": "Python",
        "level": "HIGH"
      },
      {
        "id": 211,
        "name": "Excel",
        "level": "MID"
      },
      {
        "id": 212,
        "name": "R",
        "level": "LOW"
      }
    ],
    "experiences": [],
    "portfolioLinks": [],
    "portfolioFiles": [],
    "contacts": {
      "phone": null,
      "kakaoId": "user15_k",
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": true,
      "personalEmail": false
    },
    "activityHistory": []
  },
  {
    "memberId": 16,
    "majorPrimary": "수학과",
    "majorsSecondary": [],
    "academicStatus": "GRADE_3",
    "bio": "수학과에서 데이터 분석을 공부하고 있어요",
    "fields": [
      "AI",
      "DATA"
    ],
    "skills": [
      {
        "id": 213,
        "name": "Python",
        "level": "MID"
      },
      {
        "id": 214,
        "name": "NumPy",
        "level": "LOW"
      },
      {
        "id": 215,
        "name": "scikit-learn",
        "level": "HIGH"
      }
    ],
    "experiences": [],
    "portfolioLinks": [],
    "portfolioFiles": [],
    "contacts": {
      "phone": null,
      "kakaoId": "user16_k",
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": true,
      "personalEmail": false
    },
    "activityHistory": [
      {
        "applicationId": 519,
        "postingId": 103,
        "postingTitle": "데이터 분석 학회 D:LAB 27기 모집",
        "recruiterName": "데이터 분석 학회 D:LAB",
        "announcedAt": null,
        "visible": true
      }
    ]
  },
  {
    "memberId": 17,
    "majorPrimary": "산업공학과",
    "majorsSecondary": [],
    "academicStatus": "GRADE_4",
    "bio": "산업공학과에서 데이터 분석을 공부하고 있어요",
    "fields": [
      "DATA",
      "PLANNING_MARKETING"
    ],
    "skills": [
      {
        "id": 216,
        "name": "SQL",
        "level": "LOW"
      },
      {
        "id": 217,
        "name": "Python",
        "level": "HIGH"
      },
      {
        "id": 218,
        "name": "Power BI",
        "level": "MID"
      }
    ],
    "experiences": [],
    "portfolioLinks": [],
    "portfolioFiles": [],
    "contacts": {
      "phone": null,
      "kakaoId": null,
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": false,
      "personalEmail": false
    },
    "activityHistory": [
      {
        "applicationId": 520,
        "postingId": 103,
        "postingTitle": "데이터 분석 학회 D:LAB 27기 모집",
        "recruiterName": "데이터 분석 학회 D:LAB",
        "announcedAt": null,
        "visible": true
      }
    ]
  },
  {
    "memberId": 18,
    "majorPrimary": "통계학과",
    "majorsSecondary": [],
    "academicStatus": "GRADE_1",
    "bio": "통계학과에서 데이터 분석을 공부하고 있어요",
    "fields": [
      "DATA",
      "AI"
    ],
    "skills": [
      {
        "id": 219,
        "name": "Python",
        "level": "HIGH"
      },
      {
        "id": 220,
        "name": "R",
        "level": "MID"
      },
      {
        "id": 221,
        "name": "SQL",
        "level": "LOW"
      }
    ],
    "experiences": [],
    "portfolioLinks": [],
    "portfolioFiles": [],
    "contacts": {
      "phone": null,
      "kakaoId": "user18_k",
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": true,
      "personalEmail": false
    },
    "activityHistory": [
      {
        "applicationId": 521,
        "postingId": 103,
        "postingTitle": "데이터 분석 학회 D:LAB 27기 모집",
        "recruiterName": "데이터 분석 학회 D:LAB",
        "announcedAt": null,
        "visible": true
      }
    ]
  },
  {
    "memberId": 19,
    "majorPrimary": "경영학과",
    "majorsSecondary": [],
    "academicStatus": "GRADE_2",
    "bio": "경영학과에서 데이터 분석을 공부하고 있어요",
    "fields": [
      "DATA",
      "FINANCE"
    ],
    "skills": [
      {
        "id": 222,
        "name": "Excel",
        "level": "MID"
      },
      {
        "id": 223,
        "name": "SQL",
        "level": "LOW"
      },
      {
        "id": 224,
        "name": "Tableau",
        "level": "HIGH"
      }
    ],
    "experiences": [],
    "portfolioLinks": [],
    "portfolioFiles": [],
    "contacts": {
      "phone": null,
      "kakaoId": "user19_k",
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": true,
      "personalEmail": false
    },
    "activityHistory": [
      {
        "applicationId": 522,
        "postingId": 103,
        "postingTitle": "데이터 분석 학회 D:LAB 27기 모집",
        "recruiterName": "데이터 분석 학회 D:LAB",
        "announcedAt": null,
        "visible": true
      }
    ]
  },
  {
    "memberId": 20,
    "majorPrimary": "소프트웨어학과",
    "majorsSecondary": [],
    "academicStatus": "GRADE_2",
    "bio": "소프트웨어학과에서 데이터 분석을 공부하고 있어요",
    "fields": [
      "DEV",
      "AI"
    ],
    "skills": [
      {
        "id": 225,
        "name": "Python",
        "level": "LOW"
      },
      {
        "id": 226,
        "name": "Java",
        "level": "HIGH"
      },
      {
        "id": 227,
        "name": "PyTorch",
        "level": "MID"
      }
    ],
    "experiences": [],
    "portfolioLinks": [],
    "portfolioFiles": [],
    "contacts": {
      "phone": null,
      "kakaoId": null,
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": false,
      "personalEmail": false
    },
    "activityHistory": []
  },
  {
    "memberId": 21,
    "majorPrimary": "경제학과",
    "majorsSecondary": [],
    "academicStatus": "GRADE_3",
    "bio": "경제학과에서 데이터 분석을 공부하고 있어요",
    "fields": [
      "FINANCE",
      "DATA"
    ],
    "skills": [
      {
        "id": 228,
        "name": "Python",
        "level": "HIGH"
      },
      {
        "id": 229,
        "name": "Excel",
        "level": "MID"
      },
      {
        "id": 230,
        "name": "R",
        "level": "LOW"
      }
    ],
    "experiences": [],
    "portfolioLinks": [],
    "portfolioFiles": [],
    "contacts": {
      "phone": null,
      "kakaoId": "user21_k",
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": true,
      "personalEmail": false
    },
    "activityHistory": [
      {
        "applicationId": 524,
        "postingId": 103,
        "postingTitle": "데이터 분석 학회 D:LAB 27기 모집",
        "recruiterName": "데이터 분석 학회 D:LAB",
        "announcedAt": null,
        "visible": true
      }
    ]
  },
  {
    "memberId": 22,
    "majorPrimary": "수학과",
    "majorsSecondary": [],
    "academicStatus": "GRADE_3",
    "bio": "수학과에서 데이터 분석을 공부하고 있어요",
    "fields": [
      "AI",
      "DATA"
    ],
    "skills": [
      {
        "id": 231,
        "name": "Python",
        "level": "MID"
      },
      {
        "id": 232,
        "name": "NumPy",
        "level": "LOW"
      },
      {
        "id": 233,
        "name": "scikit-learn",
        "level": "HIGH"
      }
    ],
    "experiences": [],
    "portfolioLinks": [],
    "portfolioFiles": [],
    "contacts": {
      "phone": null,
      "kakaoId": "user22_k",
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": true,
      "personalEmail": false
    },
    "activityHistory": []
  },
  {
    "memberId": 23,
    "majorPrimary": "산업공학과",
    "majorsSecondary": [],
    "academicStatus": "GRADE_4",
    "bio": "산업공학과에서 데이터 분석을 공부하고 있어요",
    "fields": [
      "DATA",
      "PLANNING_MARKETING"
    ],
    "skills": [
      {
        "id": 234,
        "name": "SQL",
        "level": "LOW"
      },
      {
        "id": 235,
        "name": "Python",
        "level": "HIGH"
      },
      {
        "id": 236,
        "name": "Power BI",
        "level": "MID"
      }
    ],
    "experiences": [],
    "portfolioLinks": [],
    "portfolioFiles": [],
    "contacts": {
      "phone": null,
      "kakaoId": null,
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": false,
      "personalEmail": false
    },
    "activityHistory": [
      {
        "applicationId": 526,
        "postingId": 103,
        "postingTitle": "데이터 분석 학회 D:LAB 27기 모집",
        "recruiterName": "데이터 분석 학회 D:LAB",
        "announcedAt": null,
        "visible": true
      }
    ]
  },
  {
    "memberId": 24,
    "majorPrimary": "통계학과",
    "majorsSecondary": [],
    "academicStatus": "GRADE_1",
    "bio": "통계학과에서 데이터 분석을 공부하고 있어요",
    "fields": [
      "DATA",
      "AI"
    ],
    "skills": [
      {
        "id": 237,
        "name": "Python",
        "level": "HIGH"
      },
      {
        "id": 238,
        "name": "R",
        "level": "MID"
      },
      {
        "id": 239,
        "name": "SQL",
        "level": "LOW"
      }
    ],
    "experiences": [],
    "portfolioLinks": [],
    "portfolioFiles": [],
    "contacts": {
      "phone": null,
      "kakaoId": "user24_k",
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": true,
      "personalEmail": false
    },
    "activityHistory": [
      {
        "applicationId": 527,
        "postingId": 103,
        "postingTitle": "데이터 분석 학회 D:LAB 27기 모집",
        "recruiterName": "데이터 분석 학회 D:LAB",
        "announcedAt": null,
        "visible": true
      }
    ]
  },
  {
    "memberId": 25,
    "majorPrimary": "경영학과",
    "majorsSecondary": [],
    "academicStatus": "GRADE_2",
    "bio": "경영학과에서 데이터 분석을 공부하고 있어요",
    "fields": [
      "DATA",
      "FINANCE"
    ],
    "skills": [
      {
        "id": 240,
        "name": "Excel",
        "level": "MID"
      },
      {
        "id": 241,
        "name": "SQL",
        "level": "LOW"
      },
      {
        "id": 242,
        "name": "Tableau",
        "level": "HIGH"
      }
    ],
    "experiences": [],
    "portfolioLinks": [],
    "portfolioFiles": [],
    "contacts": {
      "phone": null,
      "kakaoId": "user25_k",
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": true,
      "personalEmail": false
    },
    "activityHistory": [
      {
        "applicationId": 528,
        "postingId": 103,
        "postingTitle": "데이터 분석 학회 D:LAB 27기 모집",
        "recruiterName": "데이터 분석 학회 D:LAB",
        "announcedAt": null,
        "visible": true
      }
    ]
  },
  {
    "memberId": 26,
    "majorPrimary": "소프트웨어학과",
    "majorsSecondary": [],
    "academicStatus": "GRADE_2",
    "bio": "소프트웨어학과에서 데이터 분석을 공부하고 있어요",
    "fields": [
      "DEV",
      "AI"
    ],
    "skills": [
      {
        "id": 243,
        "name": "Python",
        "level": "LOW"
      },
      {
        "id": 244,
        "name": "Java",
        "level": "HIGH"
      },
      {
        "id": 245,
        "name": "PyTorch",
        "level": "MID"
      }
    ],
    "experiences": [],
    "portfolioLinks": [],
    "portfolioFiles": [],
    "contacts": {
      "phone": null,
      "kakaoId": null,
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": false,
      "personalEmail": false
    },
    "activityHistory": []
  },
  {
    "memberId": 27,
    "majorPrimary": "경제학과",
    "majorsSecondary": [],
    "academicStatus": "GRADE_3",
    "bio": "경제학과에서 데이터 분석을 공부하고 있어요",
    "fields": [
      "FINANCE",
      "DATA"
    ],
    "skills": [
      {
        "id": 246,
        "name": "Python",
        "level": "HIGH"
      },
      {
        "id": 247,
        "name": "Excel",
        "level": "MID"
      },
      {
        "id": 248,
        "name": "R",
        "level": "LOW"
      }
    ],
    "experiences": [],
    "portfolioLinks": [],
    "portfolioFiles": [],
    "contacts": {
      "phone": null,
      "kakaoId": "user27_k",
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": true,
      "personalEmail": false
    },
    "activityHistory": []
  },
  {
    "memberId": 28,
    "majorPrimary": "수학과",
    "majorsSecondary": [],
    "academicStatus": "GRADE_3",
    "bio": "수학과에서 데이터 분석을 공부하고 있어요",
    "fields": [
      "AI",
      "DATA"
    ],
    "skills": [
      {
        "id": 249,
        "name": "Python",
        "level": "MID"
      },
      {
        "id": 250,
        "name": "NumPy",
        "level": "LOW"
      },
      {
        "id": 251,
        "name": "scikit-learn",
        "level": "HIGH"
      }
    ],
    "experiences": [],
    "portfolioLinks": [],
    "portfolioFiles": [],
    "contacts": {
      "phone": null,
      "kakaoId": "user28_k",
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": true,
      "personalEmail": false
    },
    "activityHistory": [
      {
        "applicationId": 531,
        "postingId": 103,
        "postingTitle": "데이터 분석 학회 D:LAB 27기 모집",
        "recruiterName": "데이터 분석 학회 D:LAB",
        "announcedAt": null,
        "visible": true
      }
    ]
  },
  {
    "memberId": 29,
    "majorPrimary": "산업공학과",
    "majorsSecondary": [],
    "academicStatus": "GRADE_4",
    "bio": "산업공학과에서 데이터 분석을 공부하고 있어요",
    "fields": [
      "DATA",
      "PLANNING_MARKETING"
    ],
    "skills": [
      {
        "id": 252,
        "name": "SQL",
        "level": "LOW"
      },
      {
        "id": 253,
        "name": "Python",
        "level": "HIGH"
      },
      {
        "id": 254,
        "name": "Power BI",
        "level": "MID"
      }
    ],
    "experiences": [],
    "portfolioLinks": [],
    "portfolioFiles": [],
    "contacts": {
      "phone": null,
      "kakaoId": null,
      "personalEmail": null
    },
    "defaultShare": {
      "profileImage": false,
      "bio": true,
      "majorsSecondary": true,
      "skills": true,
      "experiences": true,
      "portfolioLinks": true,
      "portfolioFiles": false,
      "phone": false,
      "kakaoId": false,
      "personalEmail": false
    },
    "activityHistory": [
      {
        "applicationId": 532,
        "postingId": 103,
        "postingTitle": "데이터 분석 학회 D:LAB 27기 모집",
        "recruiterName": "데이터 분석 학회 D:LAB",
        "announcedAt": null,
        "visible": true
      }
    ]
  }
]
''';

  static const String followsJson = r'''
[
  {
    "memberId": 1,
    "orgId": 6
  },
  {
    "memberId": 2,
    "orgId": 6
  },
  {
    "memberId": 11,
    "orgId": 6
  },
  {
    "memberId": 9,
    "orgId": 7
  }
]
''';

  static const String notificationsJson = r'''
[
  {
    "id": 20001,
    "memberId": 4,
    "type": "NEW_APPLICATION",
    "title": "새 지원서가 도착했어요",
    "body": "'SQL 코딩테스트 대비 스터디원 모집 (주 2회)'에 김민준님이 지원했어요.",
    "targetScreen": "SCR-12",
    "postingId": 102,
    "applicationId": 503,
    "read": true,
    "createdDaysAgo": 5
  },
  {
    "id": 20002,
    "memberId": 4,
    "type": "NEW_APPLICATION",
    "title": "새 지원서가 도착했어요",
    "body": "'SQL 코딩테스트 대비 스터디원 모집 (주 2회)'에 한도윤님이 지원했어요.",
    "targetScreen": "SCR-12",
    "postingId": 102,
    "applicationId": 504,
    "read": true,
    "createdDaysAgo": 4
  },
  {
    "id": 20003,
    "memberId": 4,
    "type": "POSTING_CLOSED",
    "title": "모집이 마감되었어요",
    "body": "'SQL 코딩테스트 대비 스터디원 모집 (주 2회)' 지원서 2건을 검토하고 결과를 발표해 주세요.",
    "targetScreen": "SCR-12",
    "postingId": 102,
    "applicationId": null,
    "read": false,
    "createdDaysAgo": 2
  },
  {
    "id": 20004,
    "memberId": 4,
    "type": "NEW_APPLICATION",
    "title": "새 지원서가 도착했어요",
    "body": "'2026 공공데이터 활용 공모전 데이터 분석 팀원 모집'에 이서연님이 지원했어요.",
    "targetScreen": "SCR-12",
    "postingId": 101,
    "applicationId": 501,
    "read": true,
    "createdDaysAgo": 1.5
  },
  {
    "id": 20005,
    "memberId": 4,
    "type": "NEW_APPLICATION",
    "title": "새 지원서가 도착했어요",
    "body": "'2026 공공데이터 활용 공모전 데이터 분석 팀원 모집'에 최유진님이 지원했어요.",
    "targetScreen": "SCR-12",
    "postingId": 101,
    "applicationId": 502,
    "read": false,
    "createdDaysAgo": 0.8
  },
  {
    "id": 20006,
    "memberId": 6,
    "type": "POSTING_CLOSED",
    "title": "모집이 마감되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원서 24건을 검토하고 결과를 발표해 주세요.",
    "targetScreen": "SCR-12",
    "postingId": 103,
    "applicationId": null,
    "read": true,
    "createdDaysAgo": 3
  },
  {
    "id": 20007,
    "memberId": 6,
    "type": "NEW_APPLICATION",
    "title": "새 지원서가 도착했어요",
    "body": "'데이터 시각화 프로젝트 팀원 모집'에 김민준님이 지원했어요.",
    "targetScreen": "SCR-12",
    "postingId": 104,
    "applicationId": 507,
    "read": false,
    "createdDaysAgo": 0.9
  },
  {
    "id": 20008,
    "memberId": 6,
    "type": "NEW_APPLICATION",
    "title": "새 지원서가 도착했어요",
    "body": "'데이터 시각화 프로젝트 팀원 모집'에 이서연님이 지원했어요.",
    "targetScreen": "SCR-12",
    "postingId": 104,
    "applicationId": 509,
    "read": true,
    "createdDaysAgo": 0.7
  },
  {
    "id": 20009,
    "memberId": 2,
    "type": "NEW_APPLICATION",
    "title": "새 지원서가 도착했어요",
    "body": "'캠퍼스 중고거래 앱 Flutter 개발자 모집'에 윤서아님이 지원했어요.",
    "targetScreen": "SCR-12",
    "postingId": 106,
    "applicationId": 508,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20010,
    "memberId": 1,
    "type": "FOLLOWED_ORG_NEW_POSTING",
    "title": "관심 조직 새 공고",
    "body": "데이터 분석 학회 D:LAB이(가) '데이터 시각화 프로젝트 팀원 모집'을(를) 게시했습니다.",
    "targetScreen": "SCR-06",
    "postingId": 104,
    "applicationId": null,
    "read": true,
    "createdDaysAgo": 1
  },
  {
    "id": 20011,
    "memberId": 1,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 505,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20012,
    "memberId": 9,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 506,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20013,
    "memberId": 2,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 511,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20014,
    "memberId": 3,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 512,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20015,
    "memberId": 10,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 513,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20016,
    "memberId": 11,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 514,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20017,
    "memberId": 12,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 515,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20018,
    "memberId": 13,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 516,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20019,
    "memberId": 14,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 517,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20020,
    "memberId": 15,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 518,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20021,
    "memberId": 16,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 519,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20022,
    "memberId": 17,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 520,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20023,
    "memberId": 18,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 521,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20024,
    "memberId": 19,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 522,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20025,
    "memberId": 20,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 523,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20026,
    "memberId": 21,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 524,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20027,
    "memberId": 22,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 525,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20028,
    "memberId": 23,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 526,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20029,
    "memberId": 24,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 527,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20030,
    "memberId": 25,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 528,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20031,
    "memberId": 26,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 529,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20032,
    "memberId": 27,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 530,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20033,
    "memberId": 28,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 531,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20034,
    "memberId": 29,
    "type": "RESULT_ANNOUNCED",
    "title": "선발 결과가 발표되었어요",
    "body": "'데이터 분석 학회 D:LAB 27기 모집' 지원 결과를 확인해 보세요.",
    "targetScreen": "SCR-08",
    "postingId": 103,
    "applicationId": 532,
    "read": false,
    "createdDaysAgo": 0.5
  },
  {
    "id": 20035,
    "memberId": 1,
    "type": "BOOKMARK_CLOSING_SOON",
    "title": "관심 공고 마감 임박",
    "body": "'정보처리기사 실기 스터디' 모집이 24시간 안에 마감됩니다. 아직 지원하지 않았어요.",
    "targetScreen": "SCR-06",
    "postingId": 120,
    "applicationId": null,
    "read": false,
    "createdDaysAgo": 0.04
  },
  {
    "id": 20036,
    "memberId": 2,
    "type": "FOLLOWED_ORG_NEW_POSTING",
    "title": "관심 조직 새 공고",
    "body": "데이터 분석 학회 D:LAB이(가) '데이터 시각화 프로젝트 팀원 모집'을(를) 게시했습니다.",
    "targetScreen": "SCR-06",
    "postingId": 104,
    "applicationId": null,
    "read": true,
    "createdDaysAgo": 1
  },
  {
    "id": 20037,
    "memberId": 11,
    "type": "FOLLOWED_ORG_NEW_POSTING",
    "title": "관심 조직 새 공고",
    "body": "데이터 분석 학회 D:LAB이(가) '데이터 시각화 프로젝트 팀원 모집'을(를) 게시했습니다.",
    "targetScreen": "SCR-06",
    "postingId": 104,
    "applicationId": null,
    "read": false,
    "createdDaysAgo": 1
  }
]
''';

  static const String applicationsJson = r'''
[
  {
    "id": 501,
    "postingId": 101,
    "applicantId": 2,
    "snapshot": {
      "name": "이서연",
      "majorPrimary": "소프트웨어학과",
      "academicStatus": "GRADE_2",
      "fields": [
        "DATA",
        "AI"
      ],
      "bio": "데이터 시각화로 이야기를 전하고 싶은 개발자",
      "skills": [
        {
          "name": "Python",
          "level": "HIGH"
        },
        {
          "name": "SQL",
          "level": "MID"
        },
        {
          "name": "Tableau",
          "level": "MID"
        }
      ],
      "experiences": [
        {
          "type": "AWARD",
          "title": "학과 데이터 시각화 대회 장려상",
          "role": "시각화",
          "startDate": "2026-05-10",
          "endDate": "2026-05-24",
          "description": "대중교통 이용 데이터를 Tableau 대시보드로 정리했습니다."
        },
        {
          "type": "PROJECT",
          "title": "오픈소스 데이터 정제 스크립트 기여",
          "role": "컨트리뷰터",
          "startDate": "2026-07-01",
          "endDate": null,
          "description": "공공데이터 CSV 정제 도구에 결측치 처리 기능을 기여하고 있습니다."
        }
      ],
      "portfolioLinks": [
        {
          "title": "GitHub",
          "url": "https://github.com/example-seoyeon"
        }
      ],
      "portfolioFiles": [
        {
          "fileName": "포트폴리오.pdf",
          "url": "https://example.com/files/portfolio_seoyeon.pdf"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills",
      "experience:54",
      "experience:55",
      "portfolioLink:56",
      "portfolioFile:57",
      "contact:KAKAO_ID"
    ],
    "contacts": [
      {
        "type": "KAKAO_ID",
        "value": "seoyeon_data",
        "consent": true
      }
    ],
    "answers": [
      {
        "questionId": 1001,
        "value": "실제 데이터를 다루는 프로젝트 경험을 쌓고 싶어 지원했습니다. 학과 데이터 시각화 대회에서 Tableau로 대시보드를 만든 경험을 살려 분석 결과를 정리하는 역할을 맡고 싶습니다. 정기 회의에도 성실히 참여하겠습니다."
      },
      {
        "questionId": 1002,
        "value": "가능"
      },
      {
        "questionId": 1003,
        "value": "Python(Pandas), SQL, Tableau"
      }
    ],
    "withdrawn": false,
    "decision": "PENDING",
    "memo": "시각화 경험 우수, 2차 세션 리더 후보",
    "submittedDaysAgo": 1.5
  },
  {
    "id": 502,
    "postingId": 101,
    "applicantId": 3,
    "snapshot": {
      "name": "최유진",
      "majorPrimary": "디자인학과",
      "academicStatus": "GRADE_3",
      "fields": [
        "DESIGN",
        "PLANNING_MARKETING"
      ],
      "bio": "사용자 경험을 고민하는 UX 디자이너",
      "skills": [
        {
          "name": "Figma",
          "level": "HIGH"
        },
        {
          "name": "Illustrator",
          "level": "MID"
        },
        {
          "name": "Excel",
          "level": "LOW"
        }
      ],
      "experiences": [
        {
          "type": "PROJECT",
          "title": "학과 전시 웹사이트 디자인",
          "role": "UI 디자인",
          "startDate": "2026-04-01",
          "endDate": "2026-05-30",
          "description": "전시 안내 웹사이트의 화면을 설계했습니다."
        }
      ],
      "portfolioLinks": [
        {
          "title": "Behance",
          "url": "https://example.com/behance/yujin"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills",
      "experience:64",
      "portfolioLink:65",
      "contact:KAKAO_ID"
    ],
    "contacts": [
      {
        "type": "KAKAO_ID",
        "value": "yujin_ux",
        "consent": true
      }
    ],
    "answers": [
      {
        "questionId": 1001,
        "value": "분석 결과를 보고서와 대시보드로 보기 좋게 정리하는 역할을 맡고 싶습니다. Figma로 화면 설계가 가능합니다."
      },
      {
        "questionId": 1002,
        "value": "어려움"
      },
      {
        "questionId": 1003,
        "value": "Figma, Excel"
      }
    ],
    "withdrawn": false,
    "decision": "PENDING",
    "memo": null,
    "submittedDaysAgo": 0.8
  },
  {
    "id": 503,
    "postingId": 102,
    "applicantId": 1,
    "snapshot": {
      "name": "김민준",
      "majorPrimary": "소프트웨어학과",
      "academicStatus": "GRADE_3",
      "fields": [
        "DEV",
        "DATA",
        "AI"
      ],
      "majorsSecondary": [
        "통계학과"
      ],
      "bio": "데이터로 문제를 푸는 개발자",
      "skills": [
        {
          "name": "Python",
          "level": "HIGH"
        },
        {
          "name": "SQL",
          "level": "MID"
        },
        {
          "name": "Flutter",
          "level": "MID"
        },
        {
          "name": "Git",
          "level": "MID"
        }
      ],
      "experiences": [
        {
          "type": "PROJECT",
          "title": "교통 혼잡도 시각화 프로젝트",
          "role": "데이터 분석·시각화",
          "startDate": "2026-03-02",
          "endDate": "2026-06-20",
          "description": "서울시 교통량 공공데이터로 시간대별 혼잡도를 분석하고 지도 시각화를 만들었습니다."
        },
        {
          "type": "PROJECT",
          "title": "캠퍼스 중고거래 웹앱",
          "role": "백엔드 개발",
          "startDate": "2025-09-01",
          "endDate": "2025-12-15",
          "description": "Spring Boot와 MySQL로 거래 게시판·채팅 API를 구현했습니다."
        },
        {
          "type": "AWARD",
          "title": "교내 해커톤 장려상",
          "role": "팀장",
          "startDate": "2025-11-15",
          "endDate": "2025-11-16",
          "description": "공공 데이터를 활용한 캠퍼스 안내 서비스로 수상했습니다."
        }
      ],
      "portfolioLinks": [
        {
          "title": "GitHub",
          "url": "https://github.com/example-minjun"
        },
        {
          "title": "기술 블로그",
          "url": "https://example.com/blog/minjun"
        }
      ]
    },
    "sharedItems": [
      "majorsSecondary",
      "bio",
      "skills",
      "experience:21",
      "experience:22",
      "experience:23",
      "portfolioLink:31",
      "portfolioLink:32"
    ],
    "contacts": [],
    "answers": [
      {
        "questionId": 1004,
        "value": "코딩테스트 SQL 문제를 꾸준히 풀 동료가 필요해 지원합니다."
      }
    ],
    "withdrawn": false,
    "decision": "ACCEPTED",
    "memo": null,
    "submittedDaysAgo": 5
  },
  {
    "id": 504,
    "postingId": 102,
    "applicantId": 9,
    "snapshot": {
      "name": "한도윤",
      "majorPrimary": "소프트웨어학과",
      "academicStatus": "GRADE_2",
      "fields": [
        "DEV"
      ],
      "bio": "알고리즘과 백엔드를 공부하는 중",
      "skills": [
        {
          "name": "Java",
          "level": "MID"
        },
        {
          "name": "C++",
          "level": "MID"
        }
      ],
      "portfolioLinks": [
        {
          "title": "GitHub",
          "url": "https://github.com/example-doyun"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills",
      "portfolioLink:93"
    ],
    "contacts": [],
    "answers": [
      {
        "questionId": 1004,
        "value": "SQL을 처음 배우는 중이라 함께 공부하고 싶습니다."
      }
    ],
    "withdrawn": false,
    "decision": "PENDING",
    "memo": null,
    "submittedDaysAgo": 4
  },
  {
    "id": 505,
    "postingId": 103,
    "applicantId": 1,
    "snapshot": {
      "name": "김민준",
      "majorPrimary": "소프트웨어학과",
      "academicStatus": "GRADE_3",
      "fields": [
        "DEV",
        "DATA",
        "AI"
      ],
      "majorsSecondary": [
        "통계학과"
      ],
      "bio": "데이터로 문제를 푸는 개발자",
      "skills": [
        {
          "name": "Python",
          "level": "HIGH"
        },
        {
          "name": "SQL",
          "level": "MID"
        },
        {
          "name": "Flutter",
          "level": "MID"
        },
        {
          "name": "Git",
          "level": "MID"
        }
      ],
      "experiences": [
        {
          "type": "PROJECT",
          "title": "교통 혼잡도 시각화 프로젝트",
          "role": "데이터 분석·시각화",
          "startDate": "2026-03-02",
          "endDate": "2026-06-20",
          "description": "서울시 교통량 공공데이터로 시간대별 혼잡도를 분석하고 지도 시각화를 만들었습니다."
        },
        {
          "type": "PROJECT",
          "title": "캠퍼스 중고거래 웹앱",
          "role": "백엔드 개발",
          "startDate": "2025-09-01",
          "endDate": "2025-12-15",
          "description": "Spring Boot와 MySQL로 거래 게시판·채팅 API를 구현했습니다."
        },
        {
          "type": "AWARD",
          "title": "교내 해커톤 장려상",
          "role": "팀장",
          "startDate": "2025-11-15",
          "endDate": "2025-11-16",
          "description": "공공 데이터를 활용한 캠퍼스 안내 서비스로 수상했습니다."
        }
      ],
      "portfolioLinks": [
        {
          "title": "GitHub",
          "url": "https://github.com/example-minjun"
        },
        {
          "title": "기술 블로그",
          "url": "https://example.com/blog/minjun"
        }
      ]
    },
    "sharedItems": [
      "majorsSecondary",
      "bio",
      "skills",
      "experience:21",
      "experience:22",
      "experience:23",
      "portfolioLink:31",
      "portfolioLink:32",
      "contact:KAKAO_ID"
    ],
    "contacts": [
      {
        "type": "KAKAO_ID",
        "value": "minjun_k",
        "consent": true
      }
    ],
    "answers": [
      {
        "questionId": 1005,
        "value": "공공데이터 프로젝트를 하면서 분석 방법을 체계적으로 배우고 싶어졌습니다. 정기 세션에 성실히 참여하겠습니다."
      },
      {
        "questionId": 1006,
        "value": [
          "데이터 시각화",
          "SQL·데이터 엔지니어링"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "ACCEPTED",
    "memo": null,
    "submittedDaysAgo": 9
  },
  {
    "id": 506,
    "postingId": 103,
    "applicantId": 9,
    "snapshot": {
      "name": "한도윤",
      "majorPrimary": "소프트웨어학과",
      "academicStatus": "GRADE_2",
      "fields": [
        "DEV"
      ],
      "bio": "알고리즘과 백엔드를 공부하는 중",
      "skills": [
        {
          "name": "Java",
          "level": "MID"
        },
        {
          "name": "C++",
          "level": "MID"
        }
      ],
      "portfolioLinks": [
        {
          "title": "GitHub",
          "url": "https://github.com/example-doyun"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills",
      "portfolioLink:93"
    ],
    "contacts": [],
    "answers": [
      {
        "questionId": 1005,
        "value": "데이터 분석을 처음 배워 보고 싶어 지원합니다."
      },
      {
        "questionId": 1006,
        "value": [
          "머신러닝"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "REJECTED",
    "memo": null,
    "submittedDaysAgo": 8.5
  },
  {
    "id": 507,
    "postingId": 104,
    "applicantId": 1,
    "snapshot": {
      "name": "김민준",
      "majorPrimary": "소프트웨어학과",
      "academicStatus": "GRADE_3",
      "fields": [
        "DEV",
        "DATA",
        "AI"
      ],
      "majorsSecondary": [
        "통계학과"
      ],
      "bio": "데이터로 문제를 푸는 개발자",
      "skills": [
        {
          "name": "Python",
          "level": "HIGH"
        },
        {
          "name": "SQL",
          "level": "MID"
        },
        {
          "name": "Flutter",
          "level": "MID"
        },
        {
          "name": "Git",
          "level": "MID"
        }
      ],
      "experiences": [
        {
          "type": "PROJECT",
          "title": "교통 혼잡도 시각화 프로젝트",
          "role": "데이터 분석·시각화",
          "startDate": "2026-03-02",
          "endDate": "2026-06-20",
          "description": "서울시 교통량 공공데이터로 시간대별 혼잡도를 분석하고 지도 시각화를 만들었습니다."
        },
        {
          "type": "PROJECT",
          "title": "캠퍼스 중고거래 웹앱",
          "role": "백엔드 개발",
          "startDate": "2025-09-01",
          "endDate": "2025-12-15",
          "description": "Spring Boot와 MySQL로 거래 게시판·채팅 API를 구현했습니다."
        },
        {
          "type": "AWARD",
          "title": "교내 해커톤 장려상",
          "role": "팀장",
          "startDate": "2025-11-15",
          "endDate": "2025-11-16",
          "description": "공공 데이터를 활용한 캠퍼스 안내 서비스로 수상했습니다."
        }
      ],
      "portfolioLinks": [
        {
          "title": "GitHub",
          "url": "https://github.com/example-minjun"
        },
        {
          "title": "기술 블로그",
          "url": "https://example.com/blog/minjun"
        }
      ]
    },
    "sharedItems": [
      "majorsSecondary",
      "bio",
      "skills",
      "experience:21",
      "experience:22",
      "experience:23",
      "portfolioLink:31",
      "portfolioLink:32",
      "contact:SCHOOL_EMAIL"
    ],
    "contacts": [
      {
        "type": "SCHOOL_EMAIL",
        "value": "minjun.kim@g.skku.edu",
        "consent": true
      }
    ],
    "answers": [
      {
        "questionId": 1007,
        "value": "교통 혼잡도 시각화 프로젝트 경험을 살려 대시보드 개발을 맡고 싶습니다."
      },
      {
        "questionId": 1008,
        "value": [
          "시각화",
          "대시보드 개발"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "PENDING",
    "memo": null,
    "submittedDaysAgo": 0.9
  },
  {
    "id": 508,
    "postingId": 106,
    "applicantId": 10,
    "snapshot": {
      "name": "윤서아",
      "majorPrimary": "경영학과",
      "academicStatus": "GRADE_3",
      "fields": [
        "PLANNING_MARKETING",
        "DESIGN"
      ],
      "bio": "마케팅 기획과 콘텐츠 제작에 관심 있어요",
      "skills": [
        {
          "name": "Premiere Pro",
          "level": "MID"
        },
        {
          "name": "Notion",
          "level": "HIGH"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills",
      "contact:SCHOOL_EMAIL"
    ],
    "contacts": [
      {
        "type": "SCHOOL_EMAIL",
        "value": "seoa.yoon@g.skku.edu",
        "consent": true
      }
    ],
    "answers": [
      {
        "questionId": 1010,
        "value": "앱 홍보 화면과 온보딩 디자인을 함께 고민하고 싶습니다."
      },
      {
        "questionId": 1011,
        "value": "없음(배우면서 참여)"
      }
    ],
    "withdrawn": false,
    "decision": "PENDING",
    "memo": null,
    "submittedDaysAgo": 0.5
  },
  {
    "id": 509,
    "postingId": 104,
    "applicantId": 2,
    "snapshot": {
      "name": "이서연",
      "majorPrimary": "소프트웨어학과",
      "academicStatus": "GRADE_2",
      "fields": [
        "DATA",
        "AI"
      ],
      "bio": "데이터 시각화로 이야기를 전하고 싶은 개발자",
      "skills": [
        {
          "name": "Python",
          "level": "HIGH"
        },
        {
          "name": "SQL",
          "level": "MID"
        },
        {
          "name": "Tableau",
          "level": "MID"
        }
      ],
      "experiences": [
        {
          "type": "AWARD",
          "title": "학과 데이터 시각화 대회 장려상",
          "role": "시각화",
          "startDate": "2026-05-10",
          "endDate": "2026-05-24",
          "description": "대중교통 이용 데이터를 Tableau 대시보드로 정리했습니다."
        },
        {
          "type": "PROJECT",
          "title": "오픈소스 데이터 정제 스크립트 기여",
          "role": "컨트리뷰터",
          "startDate": "2026-07-01",
          "endDate": null,
          "description": "공공데이터 CSV 정제 도구에 결측치 처리 기능을 기여하고 있습니다."
        }
      ],
      "portfolioLinks": [
        {
          "title": "GitHub",
          "url": "https://github.com/example-seoyeon"
        }
      ],
      "portfolioFiles": [
        {
          "fileName": "포트폴리오.pdf",
          "url": "https://example.com/files/portfolio_seoyeon.pdf"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills",
      "experience:54",
      "experience:55",
      "portfolioLink:56",
      "portfolioFile:57",
      "contact:SCHOOL_EMAIL"
    ],
    "contacts": [
      {
        "type": "SCHOOL_EMAIL",
        "value": "seoyeon.lee@g.skku.edu",
        "consent": true
      }
    ],
    "answers": [
      {
        "questionId": 1007,
        "value": "데이터 정제 경험을 살려 전처리를 맡겠습니다."
      },
      {
        "questionId": 1008,
        "value": [
          "데이터 수집·전처리",
          "시각화"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "PENDING",
    "memo": null,
    "submittedDaysAgo": 0.7
  },
  {
    "id": 510,
    "postingId": 112,
    "applicantId": 1,
    "snapshot": {
      "name": "김민준",
      "majorPrimary": "소프트웨어학과",
      "academicStatus": "GRADE_3",
      "fields": [
        "DEV",
        "DATA",
        "AI"
      ],
      "majorsSecondary": [
        "통계학과"
      ],
      "bio": "데이터로 문제를 푸는 개발자",
      "skills": [
        {
          "name": "Python",
          "level": "HIGH"
        },
        {
          "name": "SQL",
          "level": "MID"
        },
        {
          "name": "Flutter",
          "level": "MID"
        },
        {
          "name": "Git",
          "level": "MID"
        }
      ],
      "experiences": [
        {
          "type": "PROJECT",
          "title": "교통 혼잡도 시각화 프로젝트",
          "role": "데이터 분석·시각화",
          "startDate": "2026-03-02",
          "endDate": "2026-06-20",
          "description": "서울시 교통량 공공데이터로 시간대별 혼잡도를 분석하고 지도 시각화를 만들었습니다."
        },
        {
          "type": "PROJECT",
          "title": "캠퍼스 중고거래 웹앱",
          "role": "백엔드 개발",
          "startDate": "2025-09-01",
          "endDate": "2025-12-15",
          "description": "Spring Boot와 MySQL로 거래 게시판·채팅 API를 구현했습니다."
        },
        {
          "type": "AWARD",
          "title": "교내 해커톤 장려상",
          "role": "팀장",
          "startDate": "2025-11-15",
          "endDate": "2025-11-16",
          "description": "공공 데이터를 활용한 캠퍼스 안내 서비스로 수상했습니다."
        }
      ],
      "portfolioLinks": [
        {
          "title": "GitHub",
          "url": "https://github.com/example-minjun"
        },
        {
          "title": "기술 블로그",
          "url": "https://example.com/blog/minjun"
        }
      ]
    },
    "sharedItems": [
      "majorsSecondary",
      "bio",
      "skills",
      "experience:21",
      "experience:22",
      "experience:23",
      "portfolioLink:31",
      "portfolioLink:32"
    ],
    "contacts": [],
    "answers": [
      {
        "questionId": 1015,
        "value": "투자 데이터 시각화에 관심이 있습니다."
      }
    ],
    "withdrawn": true,
    "decision": "PENDING",
    "memo": null,
    "submittedDaysAgo": 2,
    "withdrawnAt": null
  },
  {
    "id": 511,
    "postingId": 103,
    "applicantId": 2,
    "snapshot": {
      "name": "이서연",
      "majorPrimary": "소프트웨어학과",
      "academicStatus": "GRADE_2",
      "fields": [
        "DATA",
        "AI"
      ],
      "bio": "데이터 시각화로 이야기를 전하고 싶은 개발자",
      "skills": [
        {
          "name": "Python",
          "level": "HIGH"
        },
        {
          "name": "SQL",
          "level": "MID"
        },
        {
          "name": "Tableau",
          "level": "MID"
        }
      ],
      "experiences": [
        {
          "type": "AWARD",
          "title": "학과 데이터 시각화 대회 장려상",
          "role": "시각화",
          "startDate": "2026-05-10",
          "endDate": "2026-05-24",
          "description": "대중교통 이용 데이터를 Tableau 대시보드로 정리했습니다."
        },
        {
          "type": "PROJECT",
          "title": "오픈소스 데이터 정제 스크립트 기여",
          "role": "컨트리뷰터",
          "startDate": "2026-07-01",
          "endDate": null,
          "description": "공공데이터 CSV 정제 도구에 결측치 처리 기능을 기여하고 있습니다."
        }
      ],
      "portfolioLinks": [
        {
          "title": "GitHub",
          "url": "https://github.com/example-seoyeon"
        }
      ],
      "portfolioFiles": [
        {
          "fileName": "포트폴리오.pdf",
          "url": "https://example.com/files/portfolio_seoyeon.pdf"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills",
      "experience:54",
      "experience:55",
      "portfolioLink:56",
      "portfolioFile:57",
      "contact:KAKAO_ID"
    ],
    "contacts": [
      {
        "type": "KAKAO_ID",
        "value": "seoyeon_data",
        "consent": true
      }
    ],
    "answers": [
      {
        "questionId": 1005,
        "value": "실제 데이터를 다루는 프로젝트 경험을 쌓고 싶어 지원했습니다. 정기 세션에 성실히 참여하겠습니다."
      },
      {
        "questionId": 1006,
        "value": [
          "데이터 시각화",
          "머신러닝"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "ACCEPTED",
    "memo": null,
    "submittedDaysAgo": 10
  },
  {
    "id": 512,
    "postingId": 103,
    "applicantId": 3,
    "snapshot": {
      "name": "최유진",
      "majorPrimary": "디자인학과",
      "academicStatus": "GRADE_3",
      "fields": [
        "DESIGN",
        "PLANNING_MARKETING"
      ],
      "bio": "사용자 경험을 고민하는 UX 디자이너",
      "skills": [
        {
          "name": "Figma",
          "level": "HIGH"
        },
        {
          "name": "Illustrator",
          "level": "MID"
        },
        {
          "name": "Excel",
          "level": "LOW"
        }
      ],
      "experiences": [
        {
          "type": "PROJECT",
          "title": "학과 전시 웹사이트 디자인",
          "role": "UI 디자인",
          "startDate": "2026-04-01",
          "endDate": "2026-05-30",
          "description": "전시 안내 웹사이트의 화면을 설계했습니다."
        }
      ],
      "portfolioLinks": [
        {
          "title": "Behance",
          "url": "https://example.com/behance/yujin"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills",
      "experience:64",
      "portfolioLink:65",
      "contact:KAKAO_ID"
    ],
    "contacts": [
      {
        "type": "KAKAO_ID",
        "value": "yujin_ux",
        "consent": true
      }
    ],
    "answers": [
      {
        "questionId": 1005,
        "value": "분석 결과를 시각적으로 전달하는 방법을 배우고 싶습니다."
      },
      {
        "questionId": 1006,
        "value": [
          "데이터 시각화"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "ACCEPTED",
    "memo": null,
    "submittedDaysAgo": 9.5
  },
  {
    "id": 513,
    "postingId": 103,
    "applicantId": 10,
    "snapshot": {
      "name": "윤서아",
      "majorPrimary": "경영학과",
      "academicStatus": "GRADE_3",
      "fields": [
        "PLANNING_MARKETING",
        "DESIGN"
      ],
      "bio": "마케팅 기획과 콘텐츠 제작에 관심 있어요",
      "skills": [
        {
          "name": "Premiere Pro",
          "level": "MID"
        },
        {
          "name": "Notion",
          "level": "HIGH"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills"
    ],
    "contacts": [],
    "answers": [
      {
        "questionId": 1005,
        "value": "마케팅 데이터를 분석해 보고 싶습니다."
      },
      {
        "questionId": 1006,
        "value": [
          "데이터 시각화"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "REJECTED",
    "memo": null,
    "submittedDaysAgo": 9.2
  },
  {
    "id": 514,
    "postingId": 103,
    "applicantId": 11,
    "snapshot": {
      "name": "강도윤",
      "majorPrimary": "데이터사이언스융합전공",
      "academicStatus": "GRADE_3",
      "fields": [
        "AI",
        "DATA"
      ],
      "bio": "데이터 파이프라인을 만드는 데이터 엔지니어 지망생",
      "skills": [
        {
          "name": "Python",
          "level": "HIGH"
        },
        {
          "name": "SQL",
          "level": "HIGH"
        },
        {
          "name": "Docker",
          "level": "MID"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills",
      "contact:KAKAO_ID"
    ],
    "contacts": [
      {
        "type": "KAKAO_ID",
        "value": "doyoon_de",
        "consent": true
      }
    ],
    "answers": [
      {
        "questionId": 1005,
        "value": "데이터 엔지니어링 세션에서 파이프라인 경험을 나누고 싶습니다."
      },
      {
        "questionId": 1006,
        "value": [
          "SQL·데이터 엔지니어링",
          "딥러닝"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "ACCEPTED",
    "memo": null,
    "submittedDaysAgo": 8.8
  },
  {
    "id": 515,
    "postingId": 103,
    "applicantId": 12,
    "snapshot": {
      "name": "오지민",
      "majorPrimary": "통계학과",
      "academicStatus": "GRADE_1",
      "fields": [
        "DATA",
        "AI"
      ],
      "bio": "통계학과에서 데이터 분석을 공부하고 있어요",
      "skills": [
        {
          "name": "Python",
          "level": "HIGH"
        },
        {
          "name": "R",
          "level": "MID"
        },
        {
          "name": "SQL",
          "level": "LOW"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills",
      "contact:KAKAO_ID"
    ],
    "contacts": [
      {
        "type": "KAKAO_ID",
        "value": "user12_k",
        "consent": true
      }
    ],
    "answers": [
      {
        "questionId": 1005,
        "value": "전공 수업에서 배운 통계를 실제 데이터에 적용해 보고 싶습니다."
      },
      {
        "questionId": 1006,
        "value": [
          "SQL·데이터 엔지니어링"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "REJECTED",
    "memo": null,
    "submittedDaysAgo": 10.0
  },
  {
    "id": 516,
    "postingId": 103,
    "applicantId": 13,
    "snapshot": {
      "name": "신예준",
      "majorPrimary": "경영학과",
      "academicStatus": "GRADE_2",
      "fields": [
        "DATA",
        "FINANCE"
      ],
      "bio": "경영학과에서 데이터 분석을 공부하고 있어요",
      "skills": [
        {
          "name": "Excel",
          "level": "MID"
        },
        {
          "name": "SQL",
          "level": "LOW"
        },
        {
          "name": "Tableau",
          "level": "HIGH"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills",
      "contact:KAKAO_ID"
    ],
    "contacts": [
      {
        "type": "KAKAO_ID",
        "value": "user13_k",
        "consent": true
      }
    ],
    "answers": [
      {
        "questionId": 1005,
        "value": "머신러닝 프로젝트를 함께할 동료를 찾고 있습니다."
      },
      {
        "questionId": 1006,
        "value": [
          "데이터 시각화"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "ACCEPTED",
    "memo": null,
    "submittedDaysAgo": 9.6
  },
  {
    "id": 517,
    "postingId": 103,
    "applicantId": 14,
    "snapshot": {
      "name": "임하은",
      "majorPrimary": "소프트웨어학과",
      "academicStatus": "GRADE_2",
      "fields": [
        "DEV",
        "AI"
      ],
      "bio": "소프트웨어학과에서 데이터 분석을 공부하고 있어요",
      "skills": [
        {
          "name": "Python",
          "level": "LOW"
        },
        {
          "name": "Java",
          "level": "HIGH"
        },
        {
          "name": "PyTorch",
          "level": "MID"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills"
    ],
    "contacts": [],
    "answers": [
      {
        "questionId": 1005,
        "value": "데이터 분석 직무를 준비하며 포트폴리오를 만들고 싶습니다."
      },
      {
        "questionId": 1006,
        "value": [
          "데이터 시각화"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "ACCEPTED",
    "memo": null,
    "submittedDaysAgo": 9.2
  },
  {
    "id": 518,
    "postingId": 103,
    "applicantId": 15,
    "snapshot": {
      "name": "배서준",
      "majorPrimary": "경제학과",
      "academicStatus": "GRADE_3",
      "fields": [
        "FINANCE",
        "DATA"
      ],
      "bio": "경제학과에서 데이터 분석을 공부하고 있어요",
      "skills": [
        {
          "name": "Python",
          "level": "HIGH"
        },
        {
          "name": "Excel",
          "level": "MID"
        },
        {
          "name": "R",
          "level": "LOW"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills",
      "contact:KAKAO_ID"
    ],
    "contacts": [
      {
        "type": "KAKAO_ID",
        "value": "user15_k",
        "consent": true
      }
    ],
    "answers": [
      {
        "questionId": 1005,
        "value": "정기 세션으로 꾸준히 공부하는 환경이 필요해 지원합니다."
      },
      {
        "questionId": 1006,
        "value": [
          "데이터 시각화",
          "SQL·데이터 엔지니어링"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "REJECTED",
    "memo": null,
    "submittedDaysAgo": 8.8
  },
  {
    "id": 519,
    "postingId": 103,
    "applicantId": 16,
    "snapshot": {
      "name": "조아린",
      "majorPrimary": "수학과",
      "academicStatus": "GRADE_3",
      "fields": [
        "AI",
        "DATA"
      ],
      "bio": "수학과에서 데이터 분석을 공부하고 있어요",
      "skills": [
        {
          "name": "Python",
          "level": "MID"
        },
        {
          "name": "NumPy",
          "level": "LOW"
        },
        {
          "name": "scikit-learn",
          "level": "HIGH"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills",
      "contact:KAKAO_ID"
    ],
    "contacts": [
      {
        "type": "KAKAO_ID",
        "value": "user16_k",
        "consent": true
      }
    ],
    "answers": [
      {
        "questionId": 1005,
        "value": "금융 데이터 분석에 관심이 있어 다양한 사례를 배우고 싶습니다."
      },
      {
        "questionId": 1006,
        "value": [
          "머신러닝"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "ACCEPTED",
    "memo": null,
    "submittedDaysAgo": 8.4
  },
  {
    "id": 520,
    "postingId": 103,
    "applicantId": 17,
    "snapshot": {
      "name": "황민서",
      "majorPrimary": "산업공학과",
      "academicStatus": "GRADE_4",
      "fields": [
        "DATA",
        "PLANNING_MARKETING"
      ],
      "bio": "산업공학과에서 데이터 분석을 공부하고 있어요",
      "skills": [
        {
          "name": "SQL",
          "level": "LOW"
        },
        {
          "name": "Python",
          "level": "HIGH"
        },
        {
          "name": "Power BI",
          "level": "MID"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills"
    ],
    "contacts": [],
    "answers": [
      {
        "questionId": 1005,
        "value": "캐글 대회에 함께 나갈 팀을 만들고 싶습니다."
      },
      {
        "questionId": 1006,
        "value": [
          "SQL·데이터 엔지니어링",
          "데이터 시각화"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "ACCEPTED",
    "memo": null,
    "submittedDaysAgo": 8.0
  },
  {
    "id": 521,
    "postingId": 103,
    "applicantId": 18,
    "snapshot": {
      "name": "송지후",
      "majorPrimary": "통계학과",
      "academicStatus": "GRADE_1",
      "fields": [
        "DATA",
        "AI"
      ],
      "bio": "통계학과에서 데이터 분석을 공부하고 있어요",
      "skills": [
        {
          "name": "Python",
          "level": "HIGH"
        },
        {
          "name": "R",
          "level": "MID"
        },
        {
          "name": "SQL",
          "level": "LOW"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills",
      "contact:KAKAO_ID"
    ],
    "contacts": [
      {
        "type": "KAKAO_ID",
        "value": "user18_k",
        "consent": true
      }
    ],
    "answers": [
      {
        "questionId": 1005,
        "value": "전공 수업에서 배운 통계를 실제 데이터에 적용해 보고 싶습니다."
      },
      {
        "questionId": 1006,
        "value": [
          "딥러닝"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "ACCEPTED",
    "memo": null,
    "submittedDaysAgo": 7.6
  },
  {
    "id": 522,
    "postingId": 103,
    "applicantId": 19,
    "snapshot": {
      "name": "전다인",
      "majorPrimary": "경영학과",
      "academicStatus": "GRADE_2",
      "fields": [
        "DATA",
        "FINANCE"
      ],
      "bio": "경영학과에서 데이터 분석을 공부하고 있어요",
      "skills": [
        {
          "name": "Excel",
          "level": "MID"
        },
        {
          "name": "SQL",
          "level": "LOW"
        },
        {
          "name": "Tableau",
          "level": "HIGH"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills",
      "contact:KAKAO_ID"
    ],
    "contacts": [
      {
        "type": "KAKAO_ID",
        "value": "user19_k",
        "consent": true
      }
    ],
    "answers": [
      {
        "questionId": 1005,
        "value": "머신러닝 프로젝트를 함께할 동료를 찾고 있습니다."
      },
      {
        "questionId": 1006,
        "value": [
          "데이터 시각화"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "ACCEPTED",
    "memo": null,
    "submittedDaysAgo": 7.2
  },
  {
    "id": 523,
    "postingId": 103,
    "applicantId": 20,
    "snapshot": {
      "name": "홍채원",
      "majorPrimary": "소프트웨어학과",
      "academicStatus": "GRADE_2",
      "fields": [
        "DEV",
        "AI"
      ],
      "bio": "소프트웨어학과에서 데이터 분석을 공부하고 있어요",
      "skills": [
        {
          "name": "Python",
          "level": "LOW"
        },
        {
          "name": "Java",
          "level": "HIGH"
        },
        {
          "name": "PyTorch",
          "level": "MID"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills"
    ],
    "contacts": [],
    "answers": [
      {
        "questionId": 1005,
        "value": "데이터 분석 직무를 준비하며 포트폴리오를 만들고 싶습니다."
      },
      {
        "questionId": 1006,
        "value": [
          "딥러닝"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "REJECTED",
    "memo": null,
    "submittedDaysAgo": 6.8
  },
  {
    "id": 524,
    "postingId": 103,
    "applicantId": 21,
    "snapshot": {
      "name": "문시우",
      "majorPrimary": "경제학과",
      "academicStatus": "GRADE_3",
      "fields": [
        "FINANCE",
        "DATA"
      ],
      "bio": "경제학과에서 데이터 분석을 공부하고 있어요",
      "skills": [
        {
          "name": "Python",
          "level": "HIGH"
        },
        {
          "name": "Excel",
          "level": "MID"
        },
        {
          "name": "R",
          "level": "LOW"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills",
      "contact:KAKAO_ID"
    ],
    "contacts": [
      {
        "type": "KAKAO_ID",
        "value": "user21_k",
        "consent": true
      }
    ],
    "answers": [
      {
        "questionId": 1005,
        "value": "정기 세션으로 꾸준히 공부하는 환경이 필요해 지원합니다."
      },
      {
        "questionId": 1006,
        "value": [
          "데이터 시각화"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "ACCEPTED",
    "memo": null,
    "submittedDaysAgo": 6.4
  },
  {
    "id": 525,
    "postingId": 103,
    "applicantId": 22,
    "snapshot": {
      "name": "남궁윤",
      "majorPrimary": "수학과",
      "academicStatus": "GRADE_3",
      "fields": [
        "AI",
        "DATA"
      ],
      "bio": "수학과에서 데이터 분석을 공부하고 있어요",
      "skills": [
        {
          "name": "Python",
          "level": "MID"
        },
        {
          "name": "NumPy",
          "level": "LOW"
        },
        {
          "name": "scikit-learn",
          "level": "HIGH"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills",
      "contact:KAKAO_ID"
    ],
    "contacts": [
      {
        "type": "KAKAO_ID",
        "value": "user22_k",
        "consent": true
      }
    ],
    "answers": [
      {
        "questionId": 1005,
        "value": "금융 데이터 분석에 관심이 있어 다양한 사례를 배우고 싶습니다."
      },
      {
        "questionId": 1006,
        "value": [
          "머신러닝"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "REJECTED",
    "memo": null,
    "submittedDaysAgo": 6.0
  },
  {
    "id": 526,
    "postingId": 103,
    "applicantId": 23,
    "snapshot": {
      "name": "류하린",
      "majorPrimary": "산업공학과",
      "academicStatus": "GRADE_4",
      "fields": [
        "DATA",
        "PLANNING_MARKETING"
      ],
      "bio": "산업공학과에서 데이터 분석을 공부하고 있어요",
      "skills": [
        {
          "name": "SQL",
          "level": "LOW"
        },
        {
          "name": "Python",
          "level": "HIGH"
        },
        {
          "name": "Power BI",
          "level": "MID"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills"
    ],
    "contacts": [],
    "answers": [
      {
        "questionId": 1005,
        "value": "캐글 대회에 함께 나갈 팀을 만들고 싶습니다."
      },
      {
        "questionId": 1006,
        "value": [
          "SQL·데이터 엔지니어링",
          "머신러닝"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "ACCEPTED",
    "memo": null,
    "submittedDaysAgo": 5.6
  },
  {
    "id": 527,
    "postingId": 103,
    "applicantId": 24,
    "snapshot": {
      "name": "안태윤",
      "majorPrimary": "통계학과",
      "academicStatus": "GRADE_1",
      "fields": [
        "DATA",
        "AI"
      ],
      "bio": "통계학과에서 데이터 분석을 공부하고 있어요",
      "skills": [
        {
          "name": "Python",
          "level": "HIGH"
        },
        {
          "name": "R",
          "level": "MID"
        },
        {
          "name": "SQL",
          "level": "LOW"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills",
      "contact:KAKAO_ID"
    ],
    "contacts": [
      {
        "type": "KAKAO_ID",
        "value": "user24_k",
        "consent": true
      }
    ],
    "answers": [
      {
        "questionId": 1005,
        "value": "전공 수업에서 배운 통계를 실제 데이터에 적용해 보고 싶습니다."
      },
      {
        "questionId": 1006,
        "value": [
          "SQL·데이터 엔지니어링",
          "머신러닝"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "ACCEPTED",
    "memo": null,
    "submittedDaysAgo": 5.2
  },
  {
    "id": 528,
    "postingId": 103,
    "applicantId": 25,
    "snapshot": {
      "name": "고은채",
      "majorPrimary": "경영학과",
      "academicStatus": "GRADE_2",
      "fields": [
        "DATA",
        "FINANCE"
      ],
      "bio": "경영학과에서 데이터 분석을 공부하고 있어요",
      "skills": [
        {
          "name": "Excel",
          "level": "MID"
        },
        {
          "name": "SQL",
          "level": "LOW"
        },
        {
          "name": "Tableau",
          "level": "HIGH"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills",
      "contact:KAKAO_ID"
    ],
    "contacts": [
      {
        "type": "KAKAO_ID",
        "value": "user25_k",
        "consent": true
      }
    ],
    "answers": [
      {
        "questionId": 1005,
        "value": "머신러닝 프로젝트를 함께할 동료를 찾고 있습니다."
      },
      {
        "questionId": 1006,
        "value": [
          "머신러닝",
          "데이터 시각화"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "ACCEPTED",
    "memo": null,
    "submittedDaysAgo": 4.8
  },
  {
    "id": 529,
    "postingId": 103,
    "applicantId": 26,
    "snapshot": {
      "name": "서지안",
      "majorPrimary": "소프트웨어학과",
      "academicStatus": "GRADE_2",
      "fields": [
        "DEV",
        "AI"
      ],
      "bio": "소프트웨어학과에서 데이터 분석을 공부하고 있어요",
      "skills": [
        {
          "name": "Python",
          "level": "LOW"
        },
        {
          "name": "Java",
          "level": "HIGH"
        },
        {
          "name": "PyTorch",
          "level": "MID"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills"
    ],
    "contacts": [],
    "answers": [
      {
        "questionId": 1005,
        "value": "데이터 분석 직무를 준비하며 포트폴리오를 만들고 싶습니다."
      },
      {
        "questionId": 1006,
        "value": [
          "데이터 시각화"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "REJECTED",
    "memo": null,
    "submittedDaysAgo": 4.4
  },
  {
    "id": 530,
    "postingId": 103,
    "applicantId": 27,
    "snapshot": {
      "name": "노현우",
      "majorPrimary": "경제학과",
      "academicStatus": "GRADE_3",
      "fields": [
        "FINANCE",
        "DATA"
      ],
      "bio": "경제학과에서 데이터 분석을 공부하고 있어요",
      "skills": [
        {
          "name": "Python",
          "level": "HIGH"
        },
        {
          "name": "Excel",
          "level": "MID"
        },
        {
          "name": "R",
          "level": "LOW"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills",
      "contact:KAKAO_ID"
    ],
    "contacts": [
      {
        "type": "KAKAO_ID",
        "value": "user27_k",
        "consent": true
      }
    ],
    "answers": [
      {
        "questionId": 1005,
        "value": "정기 세션으로 꾸준히 공부하는 환경이 필요해 지원합니다."
      },
      {
        "questionId": 1006,
        "value": [
          "SQL·데이터 엔지니어링",
          "머신러닝"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "REJECTED",
    "memo": null,
    "submittedDaysAgo": 4.0
  },
  {
    "id": 531,
    "postingId": 103,
    "applicantId": 28,
    "snapshot": {
      "name": "차유나",
      "majorPrimary": "수학과",
      "academicStatus": "GRADE_3",
      "fields": [
        "AI",
        "DATA"
      ],
      "bio": "수학과에서 데이터 분석을 공부하고 있어요",
      "skills": [
        {
          "name": "Python",
          "level": "MID"
        },
        {
          "name": "NumPy",
          "level": "LOW"
        },
        {
          "name": "scikit-learn",
          "level": "HIGH"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills",
      "contact:KAKAO_ID"
    ],
    "contacts": [
      {
        "type": "KAKAO_ID",
        "value": "user28_k",
        "consent": true
      }
    ],
    "answers": [
      {
        "questionId": 1005,
        "value": "금융 데이터 분석에 관심이 있어 다양한 사례를 배우고 싶습니다."
      },
      {
        "questionId": 1006,
        "value": [
          "딥러닝",
          "SQL·데이터 엔지니어링"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "ACCEPTED",
    "memo": null,
    "submittedDaysAgo": 3.6
  },
  {
    "id": 532,
    "postingId": 103,
    "applicantId": 29,
    "snapshot": {
      "name": "권도현",
      "majorPrimary": "산업공학과",
      "academicStatus": "GRADE_4",
      "fields": [
        "DATA",
        "PLANNING_MARKETING"
      ],
      "bio": "산업공학과에서 데이터 분석을 공부하고 있어요",
      "skills": [
        {
          "name": "SQL",
          "level": "LOW"
        },
        {
          "name": "Python",
          "level": "HIGH"
        },
        {
          "name": "Power BI",
          "level": "MID"
        }
      ]
    },
    "sharedItems": [
      "bio",
      "skills"
    ],
    "contacts": [],
    "answers": [
      {
        "questionId": 1005,
        "value": "캐글 대회에 함께 나갈 팀을 만들고 싶습니다."
      },
      {
        "questionId": 1006,
        "value": [
          "데이터 시각화"
        ]
      }
    ],
    "withdrawn": false,
    "decision": "ACCEPTED",
    "memo": null,
    "submittedDaysAgo": 3.2
  }
]
''';

  static const String externalActivitiesJson = r'''
[
  {
    "id": 1,
    "type": "CONTEST",
    "title": "2026 공공데이터 활용 아이디어 공모전 (예시)",
    "organizer": "공공데이터 진흥기관(예시)",
    "fields": [
      "DATA",
      "AI"
    ],
    "source": "PUBLIC_API",
    "postedDaysAgo": 5,
    "deadlineDaysFromNow": 20,
    "url": "https://example.com/external/1"
  },
  {
    "id": 2,
    "type": "INTERN_JOB",
    "title": "2026 통계 체험형 청년인턴 (데이터 직무)",
    "organizer": "통계 공공기관(예시)",
    "fields": [
      "DATA"
    ],
    "source": "PUBLIC_API",
    "postedDaysAgo": 3,
    "deadlineDaysFromNow": 7,
    "url": "https://example.com/external/2"
  },
  {
    "id": 3,
    "type": "EDUCATION",
    "title": "AI 개발자 양성 부트캠프 4기 (예시)",
    "organizer": "청년 디지털 인재 지원기관(예시)",
    "fields": [
      "AI",
      "DEV"
    ],
    "source": "PUBLIC_API",
    "postedDaysAgo": 10,
    "deadlineDaysFromNow": 14,
    "url": "https://example.com/external/3"
  },
  {
    "id": 4,
    "type": "EXTRACURRICULAR",
    "title": "대학생 금융 서포터즈 모집 (예시)",
    "organizer": "금융 교육기관(예시)",
    "fields": [
      "FINANCE",
      "PLANNING_MARKETING"
    ],
    "source": "PUBLIC_API",
    "postedDaysAgo": 2,
    "deadlineDaysFromNow": 10,
    "url": "https://example.com/external/4"
  },
  {
    "id": 5,
    "type": "RESEARCH_PROGRAM",
    "title": "학부생 연구 참여 프로그램 겨울학기 모집",
    "organizer": "소프트웨어융합대학",
    "fields": [
      "AI",
      "DEV"
    ],
    "source": "SKKU_NOTICE",
    "postedDaysAgo": 6,
    "deadlineDaysFromNow": 5,
    "url": "https://example.com/external/5"
  },
  {
    "id": 6,
    "type": "CONTEST",
    "title": "대학생 UX/UI 디자인 공모전 (예시)",
    "organizer": "디자인 진흥기관(예시)",
    "fields": [
      "DESIGN"
    ],
    "source": "PUBLIC_API",
    "postedDaysAgo": 8,
    "deadlineDaysFromNow": 25,
    "url": "https://example.com/external/6"
  },
  {
    "id": 7,
    "type": "EDUCATION",
    "title": "클라우드 실무 교육 과정 (예시)",
    "organizer": "IT 교육센터(예시)",
    "fields": [
      "DEV"
    ],
    "source": "PUBLIC_API",
    "postedDaysAgo": 1,
    "deadlineDaysFromNow": null,
    "url": "https://example.com/external/7"
  },
  {
    "id": 8,
    "type": "INTERN_JOB",
    "title": "스타트업 마케팅 인턴 연계 프로그램",
    "organizer": "창업지원단",
    "fields": [
      "PLANNING_MARKETING"
    ],
    "source": "SKKU_NOTICE",
    "postedDaysAgo": 4,
    "deadlineDaysFromNow": 9,
    "url": "https://example.com/external/8"
  },
  {
    "id": 9,
    "type": "EXTRACURRICULAR",
    "title": "청년 정책 기자단 모집 (예시)",
    "organizer": "청년 정책 기관(예시)",
    "fields": [
      "ETC",
      "PLANNING_MARKETING"
    ],
    "source": "PUBLIC_API",
    "postedDaysAgo": 7,
    "deadlineDaysFromNow": 3,
    "url": "https://example.com/external/9"
  },
  {
    "id": 10,
    "type": "CONTEST",
    "title": "SW중심대학 공동 해커톤 참가자 모집",
    "organizer": "소프트웨어융합대학",
    "fields": [
      "DEV",
      "AI"
    ],
    "source": "SKKU_NOTICE",
    "postedDaysAgo": 16,
    "deadlineDaysFromNow": 4,
    "url": "https://example.com/external/10"
  }
]
''';

  static const String bookmarksJson = r'''
[
  {
    "memberId": 1,
    "targetType": "POSTING",
    "targetId": 119,
    "createdDaysAgo": 0.5
  },
  {
    "memberId": 1,
    "targetType": "POSTING",
    "targetId": 120,
    "createdDaysAgo": 2
  },
  {
    "memberId": 1,
    "targetType": "POSTING",
    "targetId": 106,
    "createdDaysAgo": 1
  },
  {
    "memberId": 1,
    "targetType": "EXTERNAL_ACTIVITY",
    "targetId": 2,
    "createdDaysAgo": 3
  },
  {
    "memberId": 1,
    "targetType": "EXTERNAL_ACTIVITY",
    "targetId": 5,
    "createdDaysAgo": 1
  },
  {
    "memberId": 2,
    "targetType": "POSTING",
    "targetId": 104,
    "createdDaysAgo": 0.8
  },
  {
    "memberId": 2,
    "targetType": "EXTERNAL_ACTIVITY",
    "targetId": 1,
    "createdDaysAgo": 4
  },
  {
    "memberId": 3,
    "targetType": "POSTING",
    "targetId": 106,
    "createdDaysAgo": 1.2
  },
  {
    "memberId": 3,
    "targetType": "EXTERNAL_ACTIVITY",
    "targetId": 6,
    "createdDaysAgo": 2
  }
]
''';

  static const String postingsJson = r'''
[
  {
    "id": 101,
    "recruiterId": 4,
    "category": "CONTEST",
    "title": "2026 공공데이터 활용 공모전 데이터 분석 팀원 모집",
    "fields": [
      "DATA",
      "AI"
    ],
    "capacity": 2,
    "deadlineDaysFromNow": 5,
    "activityStart": "2026-12-07",
    "activityEnd": "2027-01-31",
    "activityMode": "HYBRID",
    "place": "자연과학캠퍼스 디지털도서관",
    "skills": [
      "Python",
      "SQL",
      "Pandas"
    ],
    "description": "공공데이터포털의 교통·인구 데이터를 활용해 지역 문제를 분석하는 공모전에 함께할 팀원을 찾습니다. 데이터 전처리와 시각화를 함께 맡아 주실 분을 우대합니다. 결과물은 분석 보고서와 대시보드입니다.",
    "imageUrl": null,
    "questions": [
      {
        "id": 1001,
        "order": 1,
        "type": "LONG_TEXT",
        "content": "지원 동기를 적어 주세요.",
        "required": true,
        "maxLength": 500,
        "options": null
      },
      {
        "id": 1002,
        "order": 2,
        "type": "SINGLE_CHOICE",
        "content": "주 1회 오프라인 회의 참석이 가능한가요?",
        "required": true,
        "maxLength": null,
        "options": [
          "가능",
          "어려움"
        ]
      },
      {
        "id": 1003,
        "order": 3,
        "type": "SHORT_TEXT",
        "content": "사용 가능한 분석 도구를 적어 주세요.",
        "required": false,
        "maxLength": 100,
        "options": null
      }
    ],
    "requestedContacts": [
      "KAKAO_ID"
    ],
    "status": "OPEN",
    "createdDaysAgo": 2
  },
  {
    "id": 102,
    "recruiterId": 4,
    "category": "STUDY",
    "title": "SQL 코딩테스트 대비 스터디원 모집 (주 2회)",
    "fields": [
      "DATA",
      "DEV"
    ],
    "capacity": 4,
    "deadlineDaysFromNow": -2,
    "activityStart": null,
    "activityEnd": null,
    "activityMode": "ONLINE",
    "place": null,
    "skills": [
      "SQL"
    ],
    "description": "프로그래머스 SQL 고득점 Kit을 4주 동안 함께 풉니다. 매주 화·목 저녁 9시 온라인으로 진행합니다.",
    "imageUrl": null,
    "questions": [
      {
        "id": 1004,
        "order": 1,
        "type": "LONG_TEXT",
        "content": "지원 동기를 적어 주세요.",
        "required": true,
        "maxLength": 500,
        "options": null
      }
    ],
    "requestedContacts": [],
    "status": "CLOSED",
    "createdDaysAgo": 12
  },
  {
    "id": 103,
    "recruiterId": 6,
    "category": "CLUB",
    "title": "데이터 분석 학회 D:LAB 27기 모집",
    "fields": [
      "DATA",
      "AI"
    ],
    "capacity": 20,
    "deadlineDaysFromNow": -3,
    "activityStart": null,
    "activityEnd": null,
    "activityMode": "OFFLINE",
    "place": "자연과학캠퍼스 학생회관",
    "skills": [
      "Python",
      "SQL"
    ],
    "description": "D:LAB은 데이터 분석과 머신러닝을 공부하는 학회입니다. 매주 정기 세션과 학기말 프로젝트 발표가 있습니다. 전공과 학년에 관계없이 지원할 수 있습니다.",
    "imageUrl": null,
    "questions": [
      {
        "id": 1005,
        "order": 1,
        "type": "LONG_TEXT",
        "content": "지원 동기를 적어 주세요.",
        "required": true,
        "maxLength": 500,
        "options": null
      },
      {
        "id": 1006,
        "order": 2,
        "type": "MULTI_CHOICE",
        "content": "관심 있는 세션을 모두 골라 주세요.",
        "required": true,
        "maxLength": null,
        "options": [
          "데이터 시각화",
          "머신러닝",
          "딥러닝",
          "SQL·데이터 엔지니어링"
        ]
      }
    ],
    "requestedContacts": [],
    "status": "ANNOUNCED",
    "createdDaysAgo": 21,
    "announcedDaysAgo": 0.5,
    "acceptMessage": "축하합니다! 이번 주 토요일 14시에 OT가 있습니다. 아래 단체 대화방에 입장해 주세요. https://open.kakao.com/o/example",
    "rejectMessage": "지원해 주셔서 감사합니다. 다음 기수 모집에서 다시 만나기를 바랍니다."
  },
  {
    "id": 104,
    "recruiterId": 6,
    "category": "PROJECT",
    "title": "데이터 시각화 프로젝트 팀원 모집",
    "fields": [
      "DATA",
      "DESIGN"
    ],
    "capacity": 4,
    "deadlineDaysFromNow": 6,
    "activityStart": null,
    "activityEnd": null,
    "activityMode": "ONLINE",
    "place": null,
    "skills": [
      "Python",
      "Tableau"
    ],
    "description": "D:LAB 학회 프로젝트로 서울시 생활 데이터를 대시보드로 만드는 팀을 꾸립니다. 학회원이 아니어도 참여할 수 있습니다.",
    "imageUrl": null,
    "questions": [
      {
        "id": 1007,
        "order": 1,
        "type": "LONG_TEXT",
        "content": "지원 동기를 적어 주세요.",
        "required": true,
        "maxLength": 500,
        "options": null
      },
      {
        "id": 1008,
        "order": 2,
        "type": "MULTI_CHOICE",
        "content": "맡고 싶은 역할을 모두 골라 주세요.",
        "required": true,
        "maxLength": null,
        "options": [
          "데이터 수집·전처리",
          "시각화",
          "대시보드 개발"
        ]
      }
    ],
    "requestedContacts": [
      "SCHOOL_EMAIL"
    ],
    "status": "OPEN",
    "createdDaysAgo": 1
  },
  {
    "id": 105,
    "recruiterId": 7,
    "category": "CLUB",
    "title": "로봇 학회 R:BOT 신입 부원 모집",
    "fields": [
      "DEV",
      "AI"
    ],
    "capacity": 12,
    "deadlineDaysFromNow": 1.8,
    "activityStart": null,
    "activityEnd": null,
    "activityMode": "OFFLINE",
    "place": "율전 제1공학관",
    "skills": [
      "C++",
      "ROS"
    ],
    "description": "R:BOT은 자율주행 로봇과 임베디드 시스템을 다루는 학회입니다. 하드웨어 경험이 없어도 괜찮습니다.",
    "imageUrl": null,
    "questions": [
      {
        "id": 1009,
        "order": 1,
        "type": "LONG_TEXT",
        "content": "지원 동기를 적어 주세요.",
        "required": true,
        "maxLength": 500,
        "options": null
      }
    ],
    "requestedContacts": [],
    "status": "OPEN",
    "createdDaysAgo": 8
  },
  {
    "id": 106,
    "recruiterId": 2,
    "category": "PROJECT",
    "title": "캠퍼스 중고거래 앱 Flutter 개발자 모집",
    "fields": [
      "DEV"
    ],
    "capacity": 2,
    "deadlineDaysFromNow": 5,
    "activityStart": "2026-12-15",
    "activityEnd": "2027-02-28",
    "activityMode": "ONLINE",
    "place": null,
    "skills": [
      "Flutter",
      "Dart"
    ],
    "description": "학교 구성원끼리 안전하게 거래하는 중고거래 앱을 Flutter로 만듭니다. 화면 개발을 함께할 분을 찾습니다.",
    "imageUrl": null,
    "questions": [
      {
        "id": 1010,
        "order": 1,
        "type": "LONG_TEXT",
        "content": "지원 동기를 적어 주세요.",
        "required": true,
        "maxLength": 500,
        "options": null
      },
      {
        "id": 1011,
        "order": 2,
        "type": "SINGLE_CHOICE",
        "content": "Flutter 사용 경험이 있나요?",
        "required": true,
        "maxLength": null,
        "options": [
          "있음",
          "없음(배우면서 참여)"
        ]
      }
    ],
    "requestedContacts": [
      "SCHOOL_EMAIL"
    ],
    "status": "OPEN",
    "createdDaysAgo": 1
  },
  {
    "id": 107,
    "recruiterId": 2,
    "category": "STUDY",
    "title": "파이썬 데이터 분석 기초 스터디",
    "fields": [
      "DATA"
    ],
    "capacity": 5,
    "deadlineDaysFromNow": 6,
    "activityStart": null,
    "activityEnd": null,
    "activityMode": "ONLINE",
    "place": null,
    "skills": [
      "Python",
      "Pandas"
    ],
    "description": "Pandas 입문서를 6주간 함께 읽고 매주 공공데이터로 실습합니다. 비전공자도 환영합니다.",
    "imageUrl": null,
    "questions": [],
    "requestedContacts": [],
    "status": "OPEN",
    "createdDaysAgo": 4
  },
  {
    "id": 108,
    "recruiterId": 6,
    "category": "RESEARCH",
    "title": "D:LAB 추천시스템 연구 프로젝트 참여자 모집",
    "fields": [
      "AI",
      "DATA"
    ],
    "capacity": 4,
    "deadlineDaysFromNow": 12,
    "activityStart": null,
    "activityEnd": null,
    "activityMode": "HYBRID",
    "place": "자연과학캠퍼스",
    "skills": [
      "Python",
      "PyTorch"
    ],
    "description": "학회 내부 연구 프로젝트로 대학생 활동 추천 모델을 실험합니다. 논문 스터디와 실험을 함께할 분을 찾습니다.",
    "imageUrl": null,
    "questions": [
      {
        "id": 1012,
        "order": 1,
        "type": "LONG_TEXT",
        "content": "지원 동기를 적어 주세요.",
        "required": true,
        "maxLength": 500,
        "options": null
      }
    ],
    "requestedContacts": [
      "SCHOOL_EMAIL",
      "PHONE"
    ],
    "status": "OPEN",
    "createdDaysAgo": 5
  },
  {
    "id": 109,
    "recruiterId": 3,
    "category": "CONTEST",
    "title": "UX 디자인 공모전 함께할 개발자 1명",
    "fields": [
      "DESIGN",
      "DEV"
    ],
    "capacity": 1,
    "deadlineDaysFromNow": 4,
    "activityStart": null,
    "activityEnd": null,
    "activityMode": "ONLINE",
    "place": null,
    "skills": [
      "React",
      "Figma"
    ],
    "description": "디자인은 준비되어 있고, 프로토타입을 웹으로 구현해 줄 개발자 한 분을 찾습니다.",
    "imageUrl": null,
    "questions": [
      {
        "id": 1013,
        "order": 1,
        "type": "LONG_TEXT",
        "content": "지원 동기를 적어 주세요.",
        "required": true,
        "maxLength": 500,
        "options": null
      }
    ],
    "requestedContacts": [
      "KAKAO_ID"
    ],
    "status": "OPEN",
    "createdDaysAgo": 3
  },
  {
    "id": 110,
    "recruiterId": 9,
    "category": "STUDY",
    "title": "알고리즘 스터디 (백준 골드 목표)",
    "fields": [
      "DEV"
    ],
    "capacity": 6,
    "deadlineDaysFromNow": 2,
    "activityStart": null,
    "activityEnd": null,
    "activityMode": "ONLINE",
    "place": null,
    "skills": [
      "C++",
      "Java",
      "Python"
    ],
    "description": "매주 문제 5개를 풀고 일요일에 코드 리뷰를 합니다.",
    "imageUrl": null,
    "questions": [],
    "requestedContacts": [],
    "status": "OPEN",
    "createdDaysAgo": 7
  },
  {
    "id": 111,
    "recruiterId": 7,
    "category": "CONTEST",
    "title": "자율주행 로봇 경진대회 소프트웨어 파트 모집",
    "fields": [
      "AI",
      "DEV"
    ],
    "capacity": 3,
    "deadlineDaysFromNow": 8,
    "activityStart": null,
    "activityEnd": null,
    "activityMode": "OFFLINE",
    "place": "율전 제1공학관",
    "skills": [
      "Python",
      "ROS",
      "OpenCV"
    ],
    "description": "대학생 자율주행 로봇 경진대회에 나갈 팀의 인지·제어 소프트웨어 담당을 모집합니다.",
    "imageUrl": null,
    "questions": [
      {
        "id": 1014,
        "order": 1,
        "type": "LONG_TEXT",
        "content": "지원 동기를 적어 주세요.",
        "required": true,
        "maxLength": 500,
        "options": null
      }
    ],
    "requestedContacts": [
      "PHONE"
    ],
    "status": "OPEN",
    "createdDaysAgo": 2
  },
  {
    "id": 112,
    "recruiterId": 4,
    "category": "PROJECT",
    "title": "주식 데이터 대시보드 사이드 프로젝트",
    "fields": [
      "FINANCE",
      "DATA",
      "DEV"
    ],
    "capacity": 3,
    "deadlineDaysFromNow": 10,
    "activityStart": null,
    "activityEnd": null,
    "activityMode": "ONLINE",
    "place": null,
    "skills": [
      "Python",
      "Streamlit"
    ],
    "description": "공개 주가 데이터로 개인 투자 대시보드를 만드는 사이드 프로젝트입니다.",
    "imageUrl": null,
    "questions": [
      {
        "id": 1015,
        "order": 1,
        "type": "LONG_TEXT",
        "content": "지원 동기를 적어 주세요.",
        "required": true,
        "maxLength": 500,
        "options": null
      }
    ],
    "requestedContacts": [],
    "status": "OPEN",
    "createdDaysAgo": 4
  },
  {
    "id": 113,
    "recruiterId": 10,
    "category": "CONTEST",
    "title": "대학생 마케팅 공모전 기획 팀원 모집",
    "fields": [
      "PLANNING_MARKETING",
      "DESIGN"
    ],
    "capacity": 3,
    "deadlineDaysFromNow": 7,
    "activityStart": null,
    "activityEnd": null,
    "activityMode": "HYBRID",
    "place": "인문사회과학캠퍼스",
    "skills": [
      "Notion",
      "Canva"
    ],
    "description": "브랜드 캠페인 기획 공모전에 함께 나갈 기획·디자인 팀원을 찾습니다.",
    "imageUrl": null,
    "questions": [
      {
        "id": 1016,
        "order": 1,
        "type": "LONG_TEXT",
        "content": "지원 동기를 적어 주세요.",
        "required": true,
        "maxLength": 500,
        "options": null
      }
    ],
    "requestedContacts": [
      "KAKAO_ID"
    ],
    "status": "OPEN",
    "createdDaysAgo": 2
  },
  {
    "id": 114,
    "recruiterId": 9,
    "category": "STUDY",
    "title": "Spring Boot 입문 스터디",
    "fields": [
      "DEV"
    ],
    "capacity": 5,
    "deadlineDaysFromNow": 11,
    "activityStart": null,
    "activityEnd": null,
    "activityMode": "ONLINE",
    "place": null,
    "skills": [
      "Java",
      "Spring Boot"
    ],
    "description": "스프링 입문서를 함께 읽고 간단한 게시판 API를 만들어 봅니다.",
    "imageUrl": null,
    "questions": [],
    "requestedContacts": [],
    "status": "OPEN",
    "createdDaysAgo": 1
  },
  {
    "id": 115,
    "recruiterId": 6,
    "category": "STUDY",
    "title": "D:LAB 캐글 스터디 외부 참여자 모집",
    "fields": [
      "DATA",
      "AI"
    ],
    "capacity": 6,
    "deadlineDaysFromNow": 5,
    "activityStart": null,
    "activityEnd": null,
    "activityMode": "ONLINE",
    "place": null,
    "skills": [
      "Python",
      "scikit-learn"
    ],
    "description": "캐글 입문 대회를 함께 풀어 보는 스터디입니다. 학회원이 아니어도 참여할 수 있습니다.",
    "imageUrl": null,
    "questions": [
      {
        "id": 1017,
        "order": 1,
        "type": "LONG_TEXT",
        "content": "지원 동기를 적어 주세요.",
        "required": true,
        "maxLength": 500,
        "options": null
      }
    ],
    "requestedContacts": [],
    "status": "OPEN",
    "createdDaysAgo": 3
  },
  {
    "id": 116,
    "recruiterId": 10,
    "category": "PROJECT",
    "title": "교내 동아리 홍보 영상 제작 팀",
    "fields": [
      "DESIGN",
      "PLANNING_MARKETING"
    ],
    "capacity": 2,
    "deadlineDaysFromNow": 13,
    "activityStart": null,
    "activityEnd": null,
    "activityMode": "ONLINE",
    "place": null,
    "skills": [
      "Premiere Pro"
    ],
    "description": "동아리 박람회용 홍보 영상을 기획부터 편집까지 함께 만듭니다.",
    "imageUrl": null,
    "questions": [],
    "requestedContacts": [],
    "status": "OPEN",
    "createdDaysAgo": 1
  },
  {
    "id": 117,
    "recruiterId": 5,
    "category": "CONTEST",
    "title": "창업 아이디어 공모전 팀원 모집 (작성 중)",
    "fields": [
      "PLANNING_MARKETING"
    ],
    "capacity": 2,
    "deadlineDaysFromNow": 20,
    "activityStart": null,
    "activityEnd": null,
    "activityMode": "OFFLINE",
    "place": null,
    "skills": [],
    "description": "아직 작성 중인 공고입니다.",
    "imageUrl": null,
    "questions": [],
    "requestedContacts": [],
    "status": "DRAFT",
    "createdDaysAgo": 0.5
  },
  {
    "id": 118,
    "recruiterId": 5,
    "category": "CONTEST",
    "title": "금융 데이터 분석 경진대회 같이 나가실 분",
    "fields": [
      "DATA",
      "FINANCE"
    ],
    "capacity": 3,
    "deadlineDaysFromNow": 12,
    "activityStart": null,
    "activityEnd": null,
    "activityMode": "ONLINE",
    "place": null,
    "skills": [
      "Python",
      "SQL"
    ],
    "description": "카드 소비 데이터로 고객 세그먼트를 분석하는 경진대회입니다. 금융 도메인 지식은 제가 맡을게요.",
    "imageUrl": null,
    "questions": [
      {
        "id": 1018,
        "order": 1,
        "type": "LONG_TEXT",
        "content": "지원 동기를 적어 주세요.",
        "required": true,
        "maxLength": 500,
        "options": null
      }
    ],
    "requestedContacts": [
      "KAKAO_ID"
    ],
    "status": "OPEN",
    "createdDaysAgo": 2
  },
  {
    "id": 119,
    "recruiterId": 11,
    "category": "CONTEST",
    "title": "AI 해커톤 데이터 엔지니어 구합니다",
    "fields": [
      "AI",
      "DATA"
    ],
    "capacity": 2,
    "deadlineDaysFromNow": 10,
    "activityStart": null,
    "activityEnd": null,
    "activityMode": "OFFLINE",
    "place": "율전 반도체관",
    "skills": [
      "Python",
      "SQL",
      "Docker"
    ],
    "description": "무박 2일 AI 해커톤에서 데이터 수집·전처리 파이프라인을 맡아 줄 분을 찾습니다.",
    "imageUrl": null,
    "questions": [
      {
        "id": 1019,
        "order": 1,
        "type": "LONG_TEXT",
        "content": "지원 동기를 적어 주세요.",
        "required": true,
        "maxLength": 500,
        "options": null
      }
    ],
    "requestedContacts": [
      "KAKAO_ID"
    ],
    "status": "OPEN",
    "createdDaysAgo": 3
  },
  {
    "id": 120,
    "recruiterId": 9,
    "category": "STUDY",
    "title": "정보처리기사 실기 스터디",
    "fields": [
      "DEV"
    ],
    "capacity": 6,
    "deadlineDaysFromNow": 0.95,
    "activityStart": null,
    "activityEnd": null,
    "activityMode": "ONLINE",
    "place": null,
    "skills": [
      "SQL",
      "Java"
    ],
    "description": "실기 시험까지 기출 풀이를 매일 1회차씩 함께 합니다.",
    "imageUrl": null,
    "questions": [],
    "requestedContacts": [],
    "status": "OPEN",
    "createdDaysAgo": 6
  },
  {
    "id": 121,
    "recruiterId": 10,
    "category": "CONTEST",
    "title": "교내 데이터 분석 경진대회 함께 나갈 팀원",
    "fields": [
      "DATA",
      "PLANNING_MARKETING"
    ],
    "capacity": 2,
    "deadlineDaysFromNow": 9,
    "activityStart": null,
    "activityEnd": null,
    "activityMode": "HYBRID",
    "place": "인문사회과학캠퍼스",
    "skills": [
      "Excel",
      "Python"
    ],
    "description": "학생 설문 데이터를 분석해 캠퍼스 정책을 제안하는 교내 경진대회입니다.",
    "imageUrl": null,
    "questions": [
      {
        "id": 1020,
        "order": 1,
        "type": "LONG_TEXT",
        "content": "지원 동기를 적어 주세요.",
        "required": true,
        "maxLength": 500,
        "options": null
      }
    ],
    "requestedContacts": [],
    "status": "OPEN",
    "createdDaysAgo": 2
  }
]
''';

  static const String membersJson = r'''
[
  {
    "id": 1,
    "type": "PERSONAL",
    "name": "김민준",
    "schoolEmail": "minjun.kim@g.skku.edu",
    "demoDescription": "지원자 · 소프트웨어학과 3학년 (시연용 지원자)"
  },
  {
    "id": 2,
    "type": "PERSONAL",
    "name": "이서연",
    "schoolEmail": "seoyeon.lee@g.skku.edu",
    "demoDescription": "지원자 · 소프트웨어학과 2학년 (공고 106 모집자)"
  },
  {
    "id": 3,
    "type": "PERSONAL",
    "name": "최유진",
    "schoolEmail": "yujin.choi@g.skku.edu",
    "demoDescription": "지원자 · 디자인학과 3학년"
  },
  {
    "id": 4,
    "type": "PERSONAL",
    "name": "박지호",
    "schoolEmail": "jiho.park@g.skku.edu",
    "demoDescription": "개인 모집자 · 통계학과 4학년 (시연용 모집자, 공고 101)"
  },
  {
    "id": 5,
    "type": "PERSONAL",
    "name": "정하늘",
    "schoolEmail": "haneul.jung@g.skku.edu",
    "demoDescription": "개인 모집자 · 경영학과 4학년"
  },
  {
    "id": 6,
    "type": "ORGANIZATION",
    "name": "데이터 분석 학회 D:LAB",
    "contactEmail": "dlab.recruit@example.com",
    "orgType": "학회",
    "verified": true,
    "logoUrl": null,
    "orgFields": [
      "DATA",
      "AI"
    ],
    "orgIntro": "데이터 분석과 머신러닝을 함께 공부하고 프로젝트를 진행하는 성균관대학교 학회입니다. 매 학기 정기 세션과 프로젝트를 운영합니다.",
    "orgLinks": [
      {
        "title": "Instagram",
        "url": "https://example.com/instagram/dlab"
      },
      {
        "title": "웹사이트",
        "url": "https://example.com/dlab"
      }
    ],
    "demoDescription": "단체회원 · 데이터 분석 학회 (인증 완료, 27기 발표 완료)"
  },
  {
    "id": 7,
    "type": "ORGANIZATION",
    "name": "로봇 학회 R:BOT",
    "contactEmail": "rbot.recruit@example.com",
    "orgType": "학회",
    "verified": true,
    "logoUrl": null,
    "orgFields": [
      "DEV",
      "AI"
    ],
    "orgIntro": "자율주행 로봇과 임베디드 시스템을 다루는 성균관대학교 로봇 학회입니다.",
    "orgLinks": [
      {
        "title": "Instagram",
        "url": "https://example.com/instagram/rbot"
      }
    ],
    "demoDescription": "단체회원 · 로봇 학회 (인증 완료)"
  },
  {
    "id": 8,
    "type": "ADMIN",
    "name": "SKKU Crew 운영자",
    "demoDescription": "시스템 관리자"
  },
  {
    "id": 9,
    "type": "PERSONAL",
    "name": "한도윤",
    "schoolEmail": "doyun.han@g.skku.edu",
    "demoDescription": "지원자 · 소프트웨어학과 2학년"
  },
  {
    "id": 10,
    "type": "PERSONAL",
    "name": "윤서아",
    "schoolEmail": "seoa.yoon@g.skku.edu",
    "demoDescription": "지원자 · 경영학과 3학년"
  },
  {
    "id": 11,
    "type": "PERSONAL",
    "name": "강도윤",
    "schoolEmail": "doyoon.kang@g.skku.edu",
    "demoDescription": "개인 모집자 · 데이터사이언스융합전공 3학년"
  },
  {
    "id": 12,
    "type": "PERSONAL",
    "name": "오지민",
    "schoolEmail": "student12@g.skku.edu",
    "demoDescription": "지원자 (D:LAB 27기 지원)"
  },
  {
    "id": 13,
    "type": "PERSONAL",
    "name": "신예준",
    "schoolEmail": "student13@g.skku.edu",
    "demoDescription": "지원자 (D:LAB 27기 지원)"
  },
  {
    "id": 14,
    "type": "PERSONAL",
    "name": "임하은",
    "schoolEmail": "student14@g.skku.edu",
    "demoDescription": "지원자 (D:LAB 27기 지원)"
  },
  {
    "id": 15,
    "type": "PERSONAL",
    "name": "배서준",
    "schoolEmail": "student15@g.skku.edu",
    "demoDescription": "지원자 (D:LAB 27기 지원)"
  },
  {
    "id": 16,
    "type": "PERSONAL",
    "name": "조아린",
    "schoolEmail": "student16@g.skku.edu",
    "demoDescription": "지원자 (D:LAB 27기 지원)"
  },
  {
    "id": 17,
    "type": "PERSONAL",
    "name": "황민서",
    "schoolEmail": "student17@g.skku.edu",
    "demoDescription": "지원자 (D:LAB 27기 지원)"
  },
  {
    "id": 18,
    "type": "PERSONAL",
    "name": "송지후",
    "schoolEmail": "student18@g.skku.edu",
    "demoDescription": "지원자 (D:LAB 27기 지원)"
  },
  {
    "id": 19,
    "type": "PERSONAL",
    "name": "전다인",
    "schoolEmail": "student19@g.skku.edu",
    "demoDescription": "지원자 (D:LAB 27기 지원)"
  },
  {
    "id": 20,
    "type": "PERSONAL",
    "name": "홍채원",
    "schoolEmail": "student20@g.skku.edu",
    "demoDescription": "지원자 (D:LAB 27기 지원)"
  },
  {
    "id": 21,
    "type": "PERSONAL",
    "name": "문시우",
    "schoolEmail": "student21@g.skku.edu",
    "demoDescription": "지원자 (D:LAB 27기 지원)"
  },
  {
    "id": 22,
    "type": "PERSONAL",
    "name": "남궁윤",
    "schoolEmail": "student22@g.skku.edu",
    "demoDescription": "지원자 (D:LAB 27기 지원)"
  },
  {
    "id": 23,
    "type": "PERSONAL",
    "name": "류하린",
    "schoolEmail": "student23@g.skku.edu",
    "demoDescription": "지원자 (D:LAB 27기 지원)"
  },
  {
    "id": 24,
    "type": "PERSONAL",
    "name": "안태윤",
    "schoolEmail": "student24@g.skku.edu",
    "demoDescription": "지원자 (D:LAB 27기 지원)"
  },
  {
    "id": 25,
    "type": "PERSONAL",
    "name": "고은채",
    "schoolEmail": "student25@g.skku.edu",
    "demoDescription": "지원자 (D:LAB 27기 지원)"
  },
  {
    "id": 26,
    "type": "PERSONAL",
    "name": "서지안",
    "schoolEmail": "student26@g.skku.edu",
    "demoDescription": "지원자 (D:LAB 27기 지원)"
  },
  {
    "id": 27,
    "type": "PERSONAL",
    "name": "노현우",
    "schoolEmail": "student27@g.skku.edu",
    "demoDescription": "지원자 (D:LAB 27기 지원)"
  },
  {
    "id": 28,
    "type": "PERSONAL",
    "name": "차유나",
    "schoolEmail": "student28@g.skku.edu",
    "demoDescription": "지원자 (D:LAB 27기 지원)"
  },
  {
    "id": 29,
    "type": "PERSONAL",
    "name": "권도현",
    "schoolEmail": "student29@g.skku.edu",
    "demoDescription": "지원자 (D:LAB 27기 지원)"
  }
]
''';

  static const String draftsJson = r'''
[
  {
    "memberId": 1,
    "postingId": 106,
    "source": "MCP",
    "updatedDaysAgo": 0.3,
    "answers": [
      {
        "questionId": 1010,
        "value": "캠퍼스 중고거래 웹앱에서 Spring Boot로 거래·채팅 API를 만들면서, 화면을 직접 만드는 쪽에도 관심이 생겼습니다. Flutter는 프로필에 적은 것처럼 중급 정도라 화면 개발을 바로 함께할 수 있고, 백엔드 경험을 살려 API 연동도 맡겠습니다."
      },
      {
        "questionId": 1011,
        "value": "있음"
      }
    ]
  }
]
''';

}
