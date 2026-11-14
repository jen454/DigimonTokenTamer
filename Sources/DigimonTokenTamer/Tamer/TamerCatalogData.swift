// Generated from Resources/Tamer/catalog.json by scripts/gen-catalog.sh — do not edit.
enum TamerCatalogData {
    static let json = #"""
{
 "version": 1,
 "note": "Metadata only. Sprite paths are relative to the sprite pack root (tools/build_assets.sh output); no artwork is bundled. Stage info (type, attribute, signature moves) comes from DigiMonTokenBar's species data (digimon.net reference); forms missing there have no info rather than invented values. Korean names are the official Korean names (digimon.net reference_ko, which uses the localized Adventure names); koUnverified marks the four forms without an official Korean entry, transliterated instead.",
 "stages": [
  {
   "key": "0_baby1",
   "ko": "유년기 I",
   "en": "In-Training I"
  },
  {
   "key": "1_baby2",
   "ko": "유년기 II",
   "en": "In-Training II"
  },
  {
   "key": "2_rookie",
   "ko": "성장기",
   "en": "Rookie"
  },
  {
   "key": "3_champion",
   "ko": "성숙기",
   "en": "Champion"
  },
  {
   "key": "4_ultimate",
   "ko": "완전체",
   "en": "Ultimate"
  },
  {
   "key": "5_mega",
   "ko": "궁극체",
   "en": "Mega"
  }
 ],
 "lines": [
  {
   "key": "agumon",
   "ko": "아구몬",
   "crest": {
    "key": "courage",
    "ko": "용기",
    "en": "Courage",
    "color": "#d8661a"
   },
   "stages": [
    {
     "name": "Botamon",
     "ko": "깜몬",
     "sprite": "png/agumon/0_baby1_botamon.png",
     "info": {
      "type": {
       "ko": "슬라임형",
       "en": "Slime"
      },
      "attribute": {
       "ko": "",
       "en": ""
      },
      "moves": {
       "ko": [
        "산성 거품"
       ],
       "en": [
        "Acid Bubbles"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=botamon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=botamon"
      }
     }
    },
    {
     "name": "Koromon",
     "ko": "코로몬",
     "sprite": "png/agumon/1_baby2_koromon.png",
     "info": {
      "type": {
       "ko": "렛서형",
       "en": "Lesser"
      },
      "attribute": {
       "ko": "",
       "en": ""
      },
      "moves": {
       "ko": [
        "거품"
       ],
       "en": [
        "Foam"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=koromon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=koromon"
      }
     }
    },
    {
     "name": "Agumon",
     "ko": "아구몬",
     "sprite": "png/agumon/2_rookie_agumon.png",
     "info": {
      "type": {
       "ko": "파충류형",
       "en": "Reptile"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "베이비 플레임"
       ],
       "en": [
        "Pepper Breath"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=agumon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=agumon"
      }
     }
    },
    {
     "name": "Greymon",
     "ko": "그레이몬",
     "sprite": "png/agumon/3_champion_greymon.png",
     "info": {
      "type": {
       "ko": "공룡형",
       "en": "Dinosaur"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "메가파이어"
       ],
       "en": [
        "Mega Flame"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=greymon-first",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=greymon-first"
      }
     }
    },
    {
     "name": "MetalGreymon",
     "ko": "메탈그레이몬",
     "sprite": "png/agumon/4_ultimate_metalgreymon.png",
     "info": {
      "type": {
       "ko": "사이보그형",
       "en": "Cyborg"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "트라이던트 암",
        "기가 디스트로이어",
        "지가 스톰"
       ],
       "en": [
        "Trident Arm",
        "Giga Destroyer",
        "Giga Storm"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=metalgreymon-v",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=metalgreymon-v"
      }
     }
    },
    {
     "name": "WarGreymon",
     "ko": "워그레이몬",
     "sprite": "png/agumon/5_mega_wargreymon.png",
     "info": {
      "type": {
       "ko": "용인형",
       "en": "Dragon Man"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "가이아 포스",
        "브레이브 토네이도"
       ],
       "en": [
        "Terra Force",
        "Great Tornado"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=wargreymon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=wargreymon"
      }
     }
    }
   ]
  },
  {
   "key": "gabumon",
   "ko": "파피몬",
   "crest": {
    "key": "friendship",
    "ko": "우정",
    "en": "Friendship",
    "color": "#2f5fc0"
   },
   "stages": [
    {
     "name": "Punimon",
     "ko": "푸니몬",
     "sprite": "png/gabumon/0_baby1_punimon.png",
     "info": {
      "type": {
       "ko": "슬라임형",
       "en": "Slime"
      },
      "attribute": {
       "ko": "",
       "en": ""
      },
      "moves": {
       "ko": [
        "산성 거품"
       ],
       "en": [
        "Acid Bubbles"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=punimon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=punimon"
      }
     }
    },
    {
     "name": "Tsunomon",
     "ko": "뿔몬",
     "sprite": "png/gabumon/1_baby2_tsunomon.png",
     "info": {
      "type": {
       "ko": "렛서형",
       "en": "Lesser"
      },
      "attribute": {
       "ko": "",
       "en": ""
      },
      "moves": {
       "ko": [
        "산성 거품"
       ],
       "en": [
        "Acid Bubbles"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=tunomon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=tunomon"
      }
     }
    },
    {
     "name": "Gabumon",
     "ko": "파피몬",
     "sprite": "png/gabumon/2_rookie_gabumon.png",
     "info": {
      "type": {
       "ko": "파충류형",
       "en": "Reptile"
      },
      "attribute": {
       "ko": "데이터",
       "en": "Data"
      },
      "moves": {
       "ko": [
        "쁘띠 파이어"
       ],
       "en": [
        "Blue Blaster"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=gabumon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=gabumon"
      }
     }
    },
    {
     "name": "Garurumon",
     "ko": "가루몬",
     "sprite": "png/gabumon/3_champion_garurumon.png",
     "info": {
      "type": {
       "ko": "짐승형",
       "en": "Beast"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "푸른화염포"
       ],
       "en": [
        "Fox Fire"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=garurumon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=garurumon"
      }
     }
    },
    {
     "name": "WereGarurumon",
     "ko": "워가루몬",
     "sprite": "png/gabumon/4_ultimate_weregarurumon.png",
     "info": {
      "type": {
       "ko": "수인형",
       "en": "Beast Man"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "카이저 네일"
       ],
       "en": [
        "Wolf Claw"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=weregarrumon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=weregarrumon"
      }
     }
    },
    {
     "name": "MetalGarurumon",
     "ko": "메탈가루몬",
     "sprite": "png/gabumon/5_mega_metalgarurumon.png",
     "info": {
      "type": {
       "ko": "사이보그형",
       "en": "Cyborg"
      },
      "attribute": {
       "ko": "데이터",
       "en": "Data"
      },
      "moves": {
       "ko": [
        "코큐토스 브레스",
        "가루 토마호크",
        "그레이스 크로스 프리저"
       ],
       "en": [
        "Freezing Breath",
        "Garuru Tomahawk",
        "Ice Wolf Claw"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=metalgarurumon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=metalgarurumon"
      }
     }
    }
   ]
  },
  {
   "key": "biyomon",
   "ko": "피요몬",
   "crest": {
    "key": "love",
    "ko": "사랑",
    "en": "Love",
    "color": "#c83848"
   },
   "stages": [
    {
     "name": "Nyokimon",
     "ko": "뇨키몬",
     "koUnverified": true,
     "sprite": "png/biyomon/0_baby1_nyokimon.png"
    },
    {
     "name": "Yokomon",
     "ko": "어니몬",
     "sprite": "png/biyomon/1_baby2_yokomon.png",
     "info": {
      "type": {
       "ko": "알뿌리형",
       "en": "Bulb"
      },
      "attribute": {
       "ko": "",
       "en": ""
      },
      "moves": {
       "ko": [
        "샤본 플라워"
       ],
       "en": [
        "Soap Flower"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=pyocomon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=pyocomon"
      }
     }
    },
    {
     "name": "Biyomon",
     "ko": "피요몬",
     "sprite": "png/biyomon/2_rookie_biyomon.png",
     "info": {
      "type": {
       "ko": "병아리형",
       "en": "Baby Bird"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "빙빙회오리"
       ],
       "en": [
        "Spiral Twister"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=piyomon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=piyomon"
      }
     }
    },
    {
     "name": "Birdramon",
     "ko": "버드라몬",
     "sprite": "png/biyomon/3_champion_birdramon.png",
     "info": {
      "type": {
       "ko": "거조형",
       "en": "Giant Bird"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "메테오 윙"
       ],
       "en": [
        "Meteor Wing"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=birdramon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=birdramon"
      }
     }
    },
    {
     "name": "Garudamon",
     "ko": "가루다몬",
     "sprite": "png/biyomon/4_ultimate_garudamon.png",
     "info": {
      "type": {
       "ko": "조인형",
       "en": "Bird Man"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "섀도 윙"
       ],
       "en": [
        "Shadow Wing"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=garudamon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=garudamon"
      }
     }
    },
    {
     "name": "Hououmon",
     "ko": "페닉스몬",
     "sprite": "png/biyomon/5_mega_hououmon.png",
     "info": {
      "type": {
       "ko": "성수형",
       "en": "Holy Beast"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "스타라이트 익스플로전"
       ],
       "en": [
        "Starlight Explosion"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=hououmon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=hououmon"
      }
     }
    }
   ]
  },
  {
   "key": "tentomon",
   "ko": "텐타몬",
   "crest": {
    "key": "knowledge",
    "ko": "지식",
    "en": "Knowledge",
    "color": "#7046a8"
   },
   "stages": [
    {
     "name": "Pabumon",
     "ko": "뽀글몬",
     "sprite": "png/tentomon/0_baby1_pabumon.png",
     "info": {
      "type": {
       "ko": "슬라임형",
       "en": "Slime"
      },
      "attribute": {
       "ko": "",
       "en": ""
      },
      "moves": {
       "ko": [
        "점성 거품"
       ],
       "en": [
        "Adhesive Bubble Blow"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=bubbmon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=bubbmon"
      }
     }
    },
    {
     "name": "Motimon",
     "ko": "모티몬",
     "sprite": "png/tentomon/1_baby2_motimon.png",
     "info": {
      "type": {
       "ko": "렛서형",
       "en": "Lesser"
      },
      "attribute": {
       "ko": "",
       "en": ""
      },
      "moves": {
       "ko": [
        "신축성 거품"
       ],
       "en": [
        "Elastic Bubbles"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=mochimon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=mochimon"
      }
     }
    },
    {
     "name": "Tentomon",
     "ko": "텐타몬",
     "sprite": "png/tentomon/2_rookie_tentomon.png",
     "info": {
      "type": {
       "ko": "곤충형",
       "en": "Insectoid"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "쁘띠 썬더"
       ],
       "en": [
        "Super Shocker"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=tentomon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=tentomon"
      }
     }
    },
    {
     "name": "Kabuterimon",
     "ko": "캅테리몬",
     "sprite": "png/tentomon/3_champion_kabuterimon.png",
     "info": {
      "type": {
       "ko": "곤충형",
       "en": "Insectoid"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "전기충격"
       ],
       "en": [
        "Electro Shocker"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=kabuterimon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=kabuterimon"
      }
     }
    },
    {
     "name": "AtlurKabuterimon",
     "ko": "아트라캅테리몬",
     "sprite": "png/tentomon/4_ultimate_atlurkabuterimon.png",
     "info": {
      "type": {
       "ko": "곤충형",
       "en": "Insectoid"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "호른 버스터"
       ],
       "en": [
        "Horn Buster"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=atlurkabuterimon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=atlurkabuterimon"
      }
     }
    },
    {
     "name": "HerakleKabuterimon",
     "ko": "헤라클레스캅테리몬",
     "sprite": "png/tentomon/5_mega_heraklekabuterimon.png",
     "info": {
      "type": {
       "ko": "곤충형",
       "en": "Insectoid"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "기가 블래스터"
       ],
       "en": [
        "Giga Blaster"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=heraklekabuterimon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=heraklekabuterimon"
      }
     }
    }
   ]
  },
  {
   "key": "palmon",
   "ko": "팔몬",
   "crest": {
    "key": "purity",
    "ko": "순수",
    "en": "Purity",
    "color": "#3a9a2a"
   },
   "stages": [
    {
     "name": "Yuramon",
     "ko": "유라몬",
     "koUnverified": true,
     "sprite": "png/palmon/0_baby1_yuramon.png"
    },
    {
     "name": "Tanemon",
     "ko": "시드몬",
     "sprite": "png/palmon/1_baby2_tanemon.png",
     "info": {
      "type": {
       "ko": "알뿌리형",
       "en": "Bulb"
      },
      "attribute": {
       "ko": "",
       "en": ""
      },
      "moves": {
       "ko": [
        "점성 거품"
       ],
       "en": [
        "Adhesive Bubble Blow"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=tanemon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=tanemon"
      }
     }
    },
    {
     "name": "Palmon",
     "ko": "팔몬",
     "sprite": "png/palmon/2_rookie_palmon.png",
     "info": {
      "type": {
       "ko": "식물형",
       "en": "Vegetation"
      },
      "attribute": {
       "ko": "데이터",
       "en": "Data"
      },
      "moves": {
       "ko": [
        "포이즌 아이비"
       ],
       "en": [
        "Poison Ivy"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=palmon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=palmon"
      }
     }
    },
    {
     "name": "Togemon",
     "ko": "니드몬",
     "sprite": "png/palmon/3_champion_togemon.png",
     "info": {
      "type": {
       "ko": "식물형",
       "en": "Vegetation"
      },
      "attribute": {
       "ko": "데이터",
       "en": "Data"
      },
      "moves": {
       "ko": [
        "바늘 뿜기"
       ],
       "en": [
        "Needle Spray"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=togemon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=togemon"
      }
     }
    },
    {
     "name": "Lillymon",
     "ko": "릴리몬",
     "sprite": "png/palmon/4_ultimate_lillymon.png",
     "info": {
      "type": {
       "ko": "요정형",
       "en": "Pixie"
      },
      "attribute": {
       "ko": "데이터",
       "en": "Data"
      },
      "moves": {
       "ko": [
        "꽃잎 포"
       ],
       "en": [
        "Flower Cannon"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=lilimon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=lilimon"
      }
     }
    },
    {
     "name": "Rosemon",
     "ko": "로제몬",
     "sprite": "png/palmon/5_mega_rosemon.png",
     "info": {
      "type": {
       "ko": "요정형",
       "en": "Pixie"
      },
      "attribute": {
       "ko": "데이터",
       "en": "Data"
      },
      "moves": {
       "ko": [
        "쏜 위프",
        "로제스 레이피어",
        "숨겨진 유혹"
       ],
       "en": [
        "Thorn Whip",
        "Roses Rapier",
        "Forbidden Temptation"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=rosemon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=rosemon"
      }
     }
    }
   ]
  },
  {
   "key": "gomamon",
   "ko": "쉬라몬",
   "crest": {
    "key": "sincerity",
    "ko": "성실",
    "en": "Sincerity",
    "color": "#5e6670"
   },
   "stages": [
    {
     "name": "Pichimon",
     "ko": "피치몬",
     "koUnverified": true,
     "sprite": "png/gomamon/0_baby1_pichimon.png"
    },
    {
     "name": "Bukamon",
     "ko": "둥실몬",
     "sprite": "png/gomamon/1_baby2_bukamon.png",
     "info": {
      "type": {
       "ko": "렛서형",
       "en": "Lesser"
      },
      "attribute": {
       "ko": "",
       "en": ""
      },
      "moves": {
       "ko": [
        "공기 거품"
       ],
       "en": [
        "Air Bubbles"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=pukamon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=pukamon"
      }
     }
    },
    {
     "name": "Gomamon",
     "ko": "쉬라몬",
     "sprite": "png/gomamon/2_rookie_gomamon.png",
     "info": {
      "type": {
       "ko": "바다짐승형",
       "en": "Sea Beast"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "물고기 행진"
       ],
       "en": [
        "Marching Fishes"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=gomamon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=gomamon"
      }
     }
    },
    {
     "name": "Ikkakumon",
     "ko": "원뿔몬",
     "sprite": "png/gomamon/3_champion_ikkakumon.png",
     "info": {
      "type": {
       "ko": "바다짐승형",
       "en": "Sea Beast"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "뿔 날리기"
       ],
       "en": [
        "Harpoon Torpedo"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=ikkakumon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=ikkakumon"
      }
     }
    },
    {
     "name": "Zudomon",
     "ko": "쥬드몬",
     "sprite": "png/gomamon/4_ultimate_zudomon.png",
     "info": {
      "type": {
       "ko": "바다짐승형",
       "en": "Sea Beast"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "해머 스파크"
       ],
       "en": [
        "Vulcan's Hammer"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=zudomon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=zudomon"
      }
     }
    },
    {
     "name": "Vikemon",
     "ko": "바이킹몬",
     "sprite": "png/gomamon/5_mega_vikemon.png",
     "info": {
      "type": {
       "ko": "수인형",
       "en": "Beast Man"
      },
      "attribute": {
       "ko": "프리",
       "en": "Free"
      },
      "moves": {
       "ko": [
        "아크틱 블리자드",
        "묠니르"
       ],
       "en": [
        "Arctic Blizzard",
        "Mjölnir"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=vikemon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=vikemon"
      }
     }
    }
   ]
  },
  {
   "key": "patamon",
   "ko": "파닥몬",
   "crest": {
    "key": "hope",
    "ko": "희망",
    "en": "Hope",
    "color": "#c09010"
   },
   "stages": [
    {
     "name": "Poyomon",
     "ko": "포요몬",
     "sprite": "png/patamon/0_baby1_poyomon.png",
     "info": {
      "type": {
       "ko": "슬라임형",
       "en": "Slime"
      },
      "attribute": {
       "ko": "",
       "en": ""
      },
      "moves": {
       "ko": [
        "산성 거품"
       ],
       "en": [
        "Acid Bubbles"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=poyomon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=poyomon"
      }
     }
    },
    {
     "name": "Tokomon",
     "ko": "토코몬",
     "sprite": "png/patamon/1_baby2_tokomon.png",
     "info": {
      "type": {
       "ko": "렛서형",
       "en": "Lesser"
      },
      "attribute": {
       "ko": "",
       "en": ""
      },
      "moves": {
       "ko": [
        "물어뜯기"
       ],
       "en": [
        "Bite"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=tokomon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=tokomon"
      }
     }
    },
    {
     "name": "Patamon",
     "ko": "파닥몬",
     "sprite": "png/patamon/2_rookie_patamon.png",
     "info": {
      "type": {
       "ko": "포유류형",
       "en": "Mammal"
      },
      "attribute": {
       "ko": "데이터",
       "en": "Data"
      },
      "moves": {
       "ko": [
        "공기 팡",
        "날개 따귀 때리기"
       ],
       "en": [
        "Air Shot",
        "Wing Slap"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=patamon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=patamon"
      }
     }
    },
    {
     "name": "Angemon",
     "ko": "엔젤몬",
     "sprite": "png/patamon/3_champion_angemon.png",
     "info": {
      "type": {
       "ko": "천사형",
       "en": "Angel"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "헤븐즈 너클"
       ],
       "en": [
        "Heaven's Knuckle"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=angemon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=angemon"
      }
     }
    },
    {
     "name": "HolyAngemon",
     "ko": "홀리엔젤몬",
     "sprite": "png/patamon/4_ultimate_holyangemon.png",
     "info": {
      "type": {
       "ko": "대천사형",
       "en": "High Angel"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "천국의 문"
       ],
       "en": [
        "Heaven's Gate"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=holyangemon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=holyangemon"
      }
     }
    },
    {
     "name": "Seraphimon",
     "ko": "세라피몬",
     "sprite": "png/patamon/5_mega_seraphimon.png",
     "info": {
      "type": {
       "ko": "치천사형",
       "en": "Seraph"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "세븐 헤븐즈",
        "황금날개"
       ],
       "en": [
        "Strike of the Seven Stars",
        "Testament"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=seraphimon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=seraphimon"
      }
     }
    }
   ]
  },
  {
   "key": "tailmon",
   "ko": "가트몬",
   "crest": {
    "key": "light",
    "ko": "빛",
    "en": "Light",
    "color": "#c8448c"
   },
   "stages": [
    {
     "name": "YukimiBotamon",
     "ko": "유키미보타몬",
     "koUnverified": true,
     "sprite": "png/tailmon/0_baby1_yukimibotamon.png"
    },
    {
     "name": "Nyaromon",
     "ko": "야옹몬",
     "sprite": "png/tailmon/1_baby2_nyaromon.png",
     "info": {
      "type": {
       "ko": "렛서형",
       "en": "Lesser"
      },
      "attribute": {
       "ko": "",
       "en": ""
      },
      "moves": {
       "ko": [
        "폭스 테일"
       ],
       "en": [
        "Fox Tail"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=nyaromon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=nyaromon"
      }
     }
    },
    {
     "name": "Plotmon",
     "ko": "플롯트몬",
     "sprite": "png/tailmon/2_rookie_plotmon.png",
     "info": {
      "type": {
       "ko": "포유류형",
       "en": "Mammal"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "플롯트의 외침"
       ],
       "en": [
        "Puppy Howl"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=plotmon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=plotmon"
      }
     }
    },
    {
     "name": "Tailmon",
     "ko": "가트몬",
     "sprite": "png/tailmon/3_champion_tailmon.png",
     "info": {
      "type": {
       "ko": "성수형",
       "en": "Holy Beast"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "고양이 펀치",
        "최면술"
       ],
       "en": [
        "Lightning Paw",
        "Cat's Eye"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=tailmon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=tailmon"
      }
     }
    },
    {
     "name": "Angewomon",
     "ko": "엔젤우몬",
     "sprite": "png/tailmon/4_ultimate_angewomon.png",
     "info": {
      "type": {
       "ko": "대천사형",
       "en": "High Angel"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "천국의 화살",
        "천국의 미소"
       ],
       "en": [
        "Celestial Arrow",
        "Heaven's Charm"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=angewomon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=angewomon"
      }
     }
    },
    {
     "name": "Holydramon",
     "ko": "홀리드라몬",
     "sprite": "png/tailmon/5_mega_holydramon.png",
     "info": {
      "type": {
       "ko": "성룡형",
       "en": "Holy Dragon"
      },
      "attribute": {
       "ko": "백신",
       "en": "Vaccine"
      },
      "moves": {
       "ko": [
        "홀리 플레임"
       ],
       "en": [
        "Fire Tornado"
       ]
      },
      "source": {
       "ko": "https://digimon.net/reference_ko/detail.php?directory_name=holydramon",
       "en": "https://digimon.net/reference_en/detail.php?directory_name=holydramon"
      }
     }
    }
   ]
  }
 ]
}
"""#
}
