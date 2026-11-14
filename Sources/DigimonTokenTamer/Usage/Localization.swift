import Foundation

/// 앱 전체 UI 문자열 — 언어별. 단일 소스(AppLanguage)에서 파생한다.
/// 사용량·한도 문자열(상류 DigiMonTokenBar). 테이머 게임 문구는 `TamerText` 에 따로 둔다.
struct L {
    let lang: AppLanguage
    init(_ lang: AppLanguage) { self.lang = lang }

    func t(_ ko: String, _ en: String, _ ja: String, _ es: String, _ fr: String, _ pt: String, _ de: String, _ ru: String) -> String {
        switch lang {
        case .ko: return ko
        case .en: return en
        case .ja: return ja
        case .es: return es
        case .fr: return fr
        case .pt: return pt
        case .de: return de
        case .ru: return ru
        }
    }
    // MARK: 탭
    var home: String { t("홈", "Home", "ホーム", "Inicio", "Accueil", "Início", "Startseite", "Главная") }
    /// 상위 탭 이름 — 안에서 노트북/포획 로그를 세그먼트로 전환하므로 둘을 아우르는 말이어야 한다.
    /// (ko 가 "노트북"이면 탭과 세그먼트가 같은 이름이 돼 en/ja 의 Collection/コレクション 과도 어긋난다.)
    var collection: String { t("컬렉션", "Collection", "コレクション", "Colección", "Collection", "Coleção", "Sammlung", "Коллекция") }

    var costUnavailable: String { t("계산 불가", "Unavailable", "計算不可", "No disponible", "Indisponible", "Indisponível", "Nicht verfügbar", "Недоступно") }
    var costEstimateHint: String { t("모델 단가로 환산한 추정 비용입니다. 구독료나 실제 청구액이 아닙니다.", "Estimated from model token rates; not a subscription fee or invoice. Service-tier and other unlogged charges are excluded.", "モデル単価による推定です。購読料や実際の請求額ではありません。", "Estimación por tarifas del modelo; no es la cuota ni la factura real.", "Estimation selon les tarifs du modèle, pas un abonnement ni une facture.", "Estimativa pelas tarifas do modelo; não é assinatura nem fatura.", "Schätzung anhand der Modellpreise, keine Abogebühr oder Rechnung.", "Оценка по тарифам моделей за токены — не плата за подписку и не счёт. Наценки за уровень обслуживания и другие незаписанные расходы не учтены.") }
    var costReportedHint: String { t("도구가 기록한 비용입니다. 실제 청구액과 다를 수 있습니다.", "Cost recorded by the tool; it may differ from the actual bill.", "ツールが記録したコストです。実際の請求額とは異なる場合があります。", "Coste registrado por la herramienta; puede diferir de la factura.", "Coût enregistré par l’outil, pouvant différer de la facture.", "Custo registrado pela ferramenta; pode diferir da fatura.", "Vom Tool gemeldete Kosten; die Rechnung kann abweichen.", "Стоимость по данным инструмента; счёт может отличаться.") }
    var costUnavailableHint: String { t("비용 기록이나 확인된 단가·토큰 구분이 없어 계산할 수 없습니다.", "No usable cost record or verified model rate and token breakdown is available.", "コスト記録、確認済み単価、またはトークン内訳がないため計算できません。", "Faltan el coste, la tarifa verificada o el desglose de tokens.", "Coût, tarif vérifié ou détail des tokens indisponible.", "Faltam custo, tarifa verificada ou detalhamento de tokens.", "Kostenangabe, bestätigter Preis oder Token-Aufteilung fehlen.", "Нет записи о стоимости, а также проверенного тарифа модели и разбивки по токенам.") }
    var costPartialHint: String { t("일부 사용량은 계산할 수 없어 제외했습니다. 표시 금액은 계산 가능한 부분의 합계이며 청구액이 아닙니다.", "Some usage could not be priced and is excluded. This is the known portion of usage cost, not an invoice.", "計算できない使用量を除いた部分合計です。請求額ではありません。", "Total parcial: excluye uso sin precio; no es una factura.", "Total partiel hors usage non chiffrable, pas une facture.", "Total parcial sem o uso não calculável; não é uma fatura.", "Teilsumme ohne nicht berechenbare Nutzung, keine Rechnung.", "Часть расхода не удалось оценить, она исключена. Показана стоимость только известной части — это не счёт.") }

    // MARK: 헤더 (오늘/주/월)
    var todayTokens: String { t("오늘 사용한 토큰", "Today's tokens", "本日のトークン", "Tokens de hoy", "Tokens du jour", "Tokens de hoje", "Heute verbrauchte Tokens", "Токены за сегодня") }
    var today: String { t("오늘", "Today", "今日", "Hoy", "Aujourd'hui", "Hoje", "Heute", "Сегодня") }
    func unattributedClaudeUsage(_ tokens: String) -> String {
        t("이번 달 계정 미확인: \(tokens)", "Not linked to an account this month: \(tokens)", "今月アカウント不明: \(tokens)",
          "Sin cuenta asociada este mes: \(tokens)", "Non rattaché à un compte ce mois-ci : \(tokens)",
          "Sem conta associada neste mês: \(tokens)", "Diesen Monat keinem Konto zugeordnet: \(tokens)", "Без привязки к аккаунту в этом месяце: \(tokens)")
    }
    var thisWeek: String { t("이번 주", "This week", "今週", "Esta semana", "Cette semaine", "Esta semana", "Diese Woche", "Эта неделя") }
    var thisMonth: String { t("이번 달", "This month", "今月", "Este mes", "Ce mois-ci", "Este mês", "Dieser Monat", "Этот месяц") }
    /// 일별 추이 막대 행의 제목. 범위가 "이번 달"임을 문구에 담는다 — 롤링 30일로 읽히면 안 된다.
    /// de 는 "Täglich diesen Monat" 이 캡션 폭을 넘겨 줄바꿈된다(실측 79.5pt vs 66.5pt) →
    /// `weekly` 의 fr "Hebdo" 와 같은 이유로 줄인다. 바로 위 줄이 "Dieser Monat" 이라 문맥은 남는다.
    var dailyTrend: String { t("이번 달 일별", "Daily this month", "今月の日別",
                               "Diario de este mes", "Par jour ce mois-ci", "Diário deste mês",
                               "Täglich",
                               "По дням") }
    /// 추이의 최댓값 라벨 — 막대 높이가 상대값이라 절대 스케일을 한 군데는 적어줘야 한다.
    var peakDay: String { t("최다", "Peak", "最多", "Máx.", "Max.", "Máx.", "Max.", "Макс.") }

    // MARK: 한도 섹션
    var limitsOfficial: String { t("한도 (공식)", "Limits (official)", "上限（公式）", "Límites (oficial)", "Limites (officiel)", "Limites (oficiais)", "Limits (offiziell)", "Лимиты (официальные)") }
    var fiveHourNotStarted: String { t("다음 메시지부터 시작", "Starts with your next message", "次のメッセージから開始", "Empieza con tu próximo mensaje", "Démarre au prochain message", "Começa na próxima mensagem", "Beginnt mit der nächsten Nachricht", "Начнётся со следующего сообщения") }
    var fiveHourSession: String { t("5시간 세션", "5-hour session", "5時間セッション", "Sesión de 5 horas", "Session de 5 h", "Sessão de 5 horas", "5-Stunden-Sitzung", "5-часовая сессия") }
    var weekly: String { t("주간", "Weekly", "週間", "Semanal", "Hebdo", "Semanal", "Wöchentlich", "Неделя") }
    var weeklyOpus: String { t("주간 Opus", "Weekly Opus", "週間 Opus", "Opus semanal", "Opus hebdo", "Opus semanal", "Opus – wöchentlich", "Opus — неделя") }
    var weeklySonnet: String { t("주간 Sonnet", "Weekly Sonnet", "週間 Sonnet", "Sonnet semanal", "Sonnet hebdo", "Sonnet semanal", "Sonnet – wöchentlich", "Sonnet — неделя") }
    var claudeCurrentBlock: String { t("Claude 현재 5h 블록", "Claude current 5h block", "Claude 現在の5hブロック", "Bloque actual de 5h de Claude", "Bloc 5 h actuel de Claude", "Bloco atual de 5h do Claude", "Aktueller 5-Stunden-Block von Claude", "Текущий 5-часовой блок Claude") }
    var reset: String { t("리셋", "Reset", "リセット", "Reinicio", "Réinit.", "Renovação", "Zurücksetzen", "Сброс") }
    /// 페이스 눈금 툴팁. "적정 사용량"으로 부르지 않는다 — 덜 쓰라는 권고가 아니라 "이 속도면 리셋
    /// 전에 소진된다"는 기준선이고, 창을 다 채워 쓸 이유가 없는 날에 규범으로 읽히면 안 된다.
    func paceHint(_ percent: String) -> String {
        t("페이스 — 창 시간만큼 균등하게 썼다면 지금 \(percent)입니다.",
          "Pace — an even burn across this window would sit at \(percent) now.",
          "ペース — この枠を均等に使っていれば今は \(percent) です。",
          "Ritmo: un consumo uniforme en esta ventana estaría en \(percent) ahora.",
          "Rythme — une consommation régulière sur cette fenêtre serait à \(percent).",
          "Ritmo — um consumo uniforme nesta janela estaria em \(percent) agora.",
          "Tempo – bei gleichmäßigem Verbrauch in diesem Fenster wären es jetzt \(percent).",
          "Темп — при равномерном расходе в этом окне сейчас было бы \(percent).")
    }
    /// 페이스 대비 단계 이름. paceHint 와 같은 이유로 "적정"처럼 규범적인 말은 피하고
    /// 소진 속도만 묘사한다.
    func paceTier(_ tier: PaceTier) -> String {
        switch tier {
        case .wayUnder: return t("여유 많음", "Well under pace", "かなり余裕", "Muy por debajo del ritmo", "Bien sous le rythme", "Bem abaixo do ritmo", "Deutlich unter Tempo", "Намного медленнее темпа")
        case .under: return t("여유", "Under pace", "余裕あり", "Por debajo del ritmo", "Sous le rythme", "Abaixo do ritmo", "Unter Tempo", "Медленнее темпа")
        case .onPace: return t("페이스대로", "On pace", "ペース通り", "Al ritmo", "Dans le rythme", "No ritmo", "Im Tempo", "В темпе")
        case .slightlyOver: return t("조금 빠름", "Slightly fast", "やや速い", "Algo rápido", "Un peu rapide", "Um pouco rápido", "Etwas schnell", "Чуть быстрее")
        case .over: return t("빠름", "Fast", "速い", "Rápido", "Rapide", "Rápido", "Schnell", "Быстро")
        case .wayOver: return t("매우 빠름", "Very fast", "とても速い", "Muy rápido", "Très rapide", "Muito rápido", "Sehr schnell", "Очень быстро")
        }
    }
    /// 페이스 대비 차이(%p). **쓴 양**으로 말한다 — "앞섬/위" 같은 위치 표현은 잔량 모드에서
    /// 채움이 마커보다 짧게 그려질 때 방향이 반대로 읽힌다(#286 부류). 0 이면 문구 없음.
    /// 유럽어는 단계 이름("Under pace")이 이미 "페이스"를 말하므로 여기선 반복하지 않는다.
    func paceDelta(_ points: Int) -> String? {
        if points > 0 {
            return t("페이스보다 \(points)%p 더 씀", "\(points) pts more used", "ペースより\(points)pt多く使用",
                     "\(points) pts más de uso", "\(points) pts de plus utilisés",
                     "\(points) p.p. a mais de uso", "\(points) Pkt. mehr verbraucht", "потрачено на \(points) п.п. больше")
        }
        if points < 0 {
            let n = -points
            return t("페이스보다 \(n)%p 덜 씀", "\(n) pts less used", "ペースより\(n)pt少なく使用",
                     "\(n) pts menos de uso", "\(n) pts de moins utilisés",
                     "\(n) p.p. a menos de uso", "\(n) Pkt. weniger verbraucht", "потрачено на \(n) п.п. меньше")
        }
        return nil
    }
    var limitReached: String { t("한도 도달", "Limit reached", "上限到達", "Límite alcanzado", "Limite atteinte", "Limite atingido", "Limit erreicht", "Лимит исчерпан") }
    var personalSpendLimit: String { t("개인 사용 한도", "Personal spend limit", "個人利用上限", "Límite de gasto personal", "Limite de dépense personnelle", "Limite de gasto pessoal", "Persönliches Ausgabenlimit", "Личный лимит расходов") }
    var staleLimits: String { t("갱신 지연", "Stale", "更新遅延", "Desactualizado", "Périmé", "Desatualizado", "Nicht aktuell", "Устарело") }
    var refresh: String { t("갱신", "Refresh", "更新", "Actualizar", "Actualiser", "Atualizar", "Aktualisieren", "Обновить") }
    var limitsTapToLoad: String { t("공식 한도 불러오기", "Load official limits", "公式上限を読み込む", "Cargar límites oficiales", "Charger les limites officielles", "Carregar limites oficiais", "Offizielle Limits laden", "Загрузить официальные лимиты") }

    /// 프로바이더 상태 페이지 인시던트 지표 → 현지화 라벨(표시 전용).
    func providerStatusLabel(_ indicator: ProviderStatusIndicator) -> String {
        switch indicator {
        case .operational: return t("정상", "Operational", "正常", "Operativo", "Opérationnel", "Operacional", "Betriebsbereit", "Работает штатно")
        case .minor:       return t("일부 장애", "Minor issues", "一部障害", "Problemas menores", "Problèmes mineurs", "Problemas menores", "Kleinere Störungen", "Небольшие сбои")
        case .major:       return t("장애", "Major outage", "障害", "Interrupción grave", "Panne majeure", "Interrupção grave", "Großer Ausfall", "Серьёзный сбой")
        case .critical:    return t("심각한 장애", "Critical outage", "重大障害", "Interrupción crítica", "Panne critique", "Interrupção crítica", "Kritischer Ausfall", "Критический сбой")
        case .maintenance: return t("점검 중", "Maintenance", "メンテナンス", "Mantenimiento", "Maintenance", "Manutenção", "Wartung", "Техобслуживание")
        case .unknown:     return t("상태 불명", "Status unknown", "状態不明", "Estado desconocido", "État inconnu", "Status desconhecido", "Status unbekannt", "Статус неизвестен")
        }
    }
    func plan(_ p: String) -> String { t("플랜 \(p)", "Plan \(p)", "プラン \(p)", "Plan \(p)", "Forfait \(p)", "Plano \(p)", "Tarif \(p)", "Тариф \(p)") }
    func limitsAccount(_ a: String) -> String { t("계정 \(a)", "Account \(a)", "アカウント \(a)", "Cuenta \(a)", "Compte \(a)", "Conta \(a)", "Konto \(a)", "Аккаунт \(a)") }
    func forecastReach(_ time: String) -> String {
        t("현재 속도면 \(time) 한도 도달", "At current rate, limit hit at \(time)", "現在のペースで \(time) に上限到達", "Al ritmo actual, límite alcanzado a las \(time)", "À ce rythme, limite atteinte à \(time)", "No ritmo atual, limite atingido às \(time)", "Bei diesem Tempo erreichst du das Limit um \(time)", "При текущем темпе лимит будет исчерпан в \(time)")
    }
    var forecastNoReach: String {
        t("현재 속도로는 리셋 전 한도 도달 없음", "Won't hit limit before reset at current rate", "現在のペースではリセット前に上限到達なし", "Al ritmo actual, no alcanzarás el límite antes del reinicio", "À ce rythme, tu n'atteindras pas la limite avant la réinit.", "No ritmo atual, você não vai bater o limite antes da renovação", "Bei diesem Tempo erreichst du das Limit nicht vor dem Zurücksetzen", "При текущем темпе лимита хватит до сброса")
    }

    /// Claude oauth/usage 신형 limits[] 엔트리 이름 — kind + 모델 스코프 기반.
    func claudeLimitEntry(kind: String?, model: String?) -> String {
        switch kind {
        case "session": return fiveHourSession
        case "weekly_all": return weekly
        case "weekly_scoped":
            // 모델명이 없으면 레거시 "주간" 행과 이름이 겹치므로 scoped 임을 구분 표기
            guard let model else { return t("주간 (모델별)", "Weekly (scoped)", "週間（モデル別）", "Semanal (por modelo)", "Hebdo (par modèle)", "Semanal (por modelo)", "Wöchentlich (pro Modell)", "Неделя (по моделям)") }
            return t("주간 \(model)", "Weekly \(model)", "週間 \(model)", "Semanal \(model)", "Hebdo \(model)", "Semanal \(model)", "\(model) – wöchentlich", "\(model) — неделя")
        default:
            let base = kind ?? "limit"
            let name = model.map { " \($0)" } ?? ""
            return base.replacingOccurrences(of: "_", with: " ") + name
        }
    }

    /// Codex 한도 윈도우 이름 (windowDurationMins 기반). 알림·팝오버 공통.
    func codexWindow(_ mins: Int?) -> String {
        switch mins {
        case 300: return fiveHourSession
        case 10_080: return weekly
        case let m? where m >= 60 && m % 60 == 0:
            let h = m / 60
            return t("\(h)시간", "\(h)h", "\(h)時間", "\(h)h", "\(h) h", "\(h)h", "\(h) Std.", "\(h) ч")
        case let m?: return t("\(m)분", "\(m)m", "\(m)分", "\(m)m", "\(m) min", "\(m) min", "\(m) Min.", "\(m) мин")
        case nil: return t("한도", "Limit", "上限", "Límite", "Limite", "Limite", "Limit", "Лимит")
        }
    }

    /// Antigravity 한도 그룹 및 윈도우 이름
    var antigravityGeminiGroup: String { t("Gemini 모델군", "Gemini Models", "Gemini モデル群", "Modelos Gemini", "Modèles Gemini", "Modelos Gemini", "Gemini-Modelle", "Модели Gemini") }
    var antigravityThirdPartyGroup: String { t("Claude & GPT 모델군", "Claude & GPT Models", "Claude & GPT モデル群", "Modelos Claude y GPT", "Modèles Claude et GPT", "Modelos Claude e GPT", "Claude- & GPT-Modelle", "Модели Claude и GPT") }
    /// API `displayName` ("Gemini Models", "Claude and GPT models", …) → 앱 언어 라벨.
    /// 팝오버·한도 알림·사탕 알림·펫 버블이 같은 매핑을 써야 한 화면 두 언어가 안 난다(#322).
    /// 판정은 `AntigravityRateLimitStatus.geminiGroup` / `thirdPartyGroup` 과 같은 축(gemini /
    /// claude|gpt|3p). 모르는 이름은 API 문자열을 그대로 둔다.
    func antigravityGroupTitle(_ displayName: String) -> String {
        if displayName.localizedCaseInsensitiveContains("gemini") { return antigravityGeminiGroup }
        if displayName.localizedCaseInsensitiveContains("claude")
            || displayName.localizedCaseInsensitiveContains("gpt")
            || displayName.localizedCaseInsensitiveContains("3p") {
            return antigravityThirdPartyGroup
        }
        return displayName
    }
    func antigravityWindow(window: String?, bucketId: String) -> String {
        if window == "5h" || bucketId.contains("5h") {
            return fiveHourSession
        }
        if window == "weekly" || bucketId.contains("weekly") {
            return weekly
        }
        return t("한도", "Limit", "上限", "Límite", "Limite", "Limite", "Limit", "Лимит")
    }

    // MARK: 푸터
    var refreshNow: String { t("지금 새로고침", "Refresh now", "今すぐ更新", "Actualizar ahora", "Actualiser maintenant", "Atualizar agora", "Jetzt aktualisieren", "Обновить сейчас") }
    var updated: String { t("갱신", "Updated", "更新", "Actualizado", "Mis à jour", "Atualizado", "Aktualisiert", "Обновлено") }
    var settings: String { t("설정", "Settings", "設定", "Ajustes", "Réglages", "Ajustes", "Einstellungen", "Настройки") }
    var tokenInput: String { t("입력", "Input", "入力", "Entrada", "Entrée", "Entrada", "Eingabe", "Ввод") }
    var tokenOutput: String { t("출력", "Output", "出力", "Salida", "Sortie", "Saída", "Ausgabe", "Вывод") }
    var tokenCacheWrite: String { t("캐시 쓰기", "Cache write", "キャッシュ書込", "Escritura caché", "Écriture cache", "Gravação cache", "Cache schreiben", "Запись в кэш") }
    var tokenCacheRead: String { t("캐시 읽기", "Cache read", "キャッシュ読込", "Lectura caché", "Lecture cache", "Leitura cache", "Cache lesen", "Чтение кэша") }
    var website: String { t("웹사이트", "Website", "ウェブサイト", "Sitio web", "Site web", "Site", "Website", "Сайт") }
    var sponsor: String { t("후원", "Sponsor", "支援", "Apoyar", "Soutenir", "Apoiar", "Unterstützen", "Поддержать") }
    var evolutionScrollPrevious: String { t("이전 진화 보기", "Show previous evolutions", "前の進化を見る", "Ver evoluciones anteriores", "Voir les évolutions précédentes", "Ver evoluções anteriores", "Vorherige Entwicklungen anzeigen", "Показать предыдущие эволюции") }
    var evolutionScrollNext: String { t("다음 진화 보기", "Show next evolutions", "次の進化を見る", "Ver evoluciones siguientes", "Voir les évolutions suivantes", "Ver próximas evoluções", "Nächste Entwicklungen anzeigen", "Показать следующие эволюции") }

    var back: String { t("뒤로", "Back", "戻る", "Atrás", "Retour", "Voltar", "Zurück", "Назад") }

    // MARK: Usage recap
    var recapOpen: String { t("사용량 돌아보기", "Usage recap", "使用量のふりかえり", "Resumen de uso", "Récap d'utilisation", "Resumo de uso", "Nutzungsrückblick", "Итоги расхода") }
    var recapTokensUnit: String { t("토큰", "tokens", "トークン", "tokens", "tokens", "tokens", "Tokens", "токенов") }
    func recapScopeName(_ scope: RecapScope) -> String {
        switch scope {
        case .week: t("주간", "Week", "週", "Semana", "Semaine", "Semana", "Woche", "Неделя")
        case .month: t("월간", "Month", "月", "Mes", "Mois", "Mês", "Monat", "Месяц")
        case .year: t("연간", "Year", "年", "Año", "Année", "Ano", "Jahr", "Год")
        }
    }
    /// Shown under a running period, whose chip compares the same number of days.
    func recapCompareSoFar(_ scope: RecapScope) -> String {
        switch scope {
        case .week: t("지난주 같은 기간과 비교", "Compared with the same days last week", "先週の同じ期間と比較",
                      "Comparado con los mismos días de la semana pasada", "Comparé aux mêmes jours de la semaine dernière",
                      "Comparado com os mesmos dias da semana passada", "Verglichen mit denselben Tagen der Vorwoche", "По сравнению с теми же днями прошлой недели")
        case .month: t("지난달 같은 기간과 비교", "Compared with the same days last month", "先月の同じ期間と比較",
                       "Comparado con los mismos días del mes pasado", "Comparé aux mêmes jours du mois dernier",
                       "Comparado com os mesmos dias do mês passado", "Verglichen mit denselben Tagen des Vormonats", "По сравнению с теми же днями прошлого месяца")
        case .year: t("작년 같은 기간과 비교", "Compared with the same days last year", "昨年の同じ期間と比較",
                      "Comparado con los mismos días del año pasado", "Comparé aux mêmes jours de l'an dernier",
                      "Comparado com os mesmos dias do ano passado", "Verglichen mit denselben Tagen des Vorjahres", "По сравнению с теми же днями прошлого года")
        }
    }
    func recapCurrentPeriod(_ scope: RecapScope) -> String {
        switch scope {
        case .week: thisWeek
        case .month: thisMonth
        case .year: t("올해", "This year", "今年", "Este año", "Cette année", "Este ano", "Dieses Jahr", "Этот год")
        }
    }
    var recapPrevious: String { t("이전", "Previous", "前へ", "Anterior", "Précédent", "Anterior", "Vorherige", "Назад") }
    var recapNext: String { t("다음", "Next", "次へ", "Siguiente", "Suivant", "Próximo", "Nächste", "Вперёд") }
    var recapBestDay: String { t("최고의 날", "Best day", "最高の日", "Mejor día", "Meilleur jour", "Melhor dia", "Bester Tag", "Лучший день") }
    var recapActiveDays: String { t("활동한 날", "Active days", "稼働日", "Días activos", "Jours actifs", "Dias ativos", "Aktive Tage", "Активных дней") }
    var recapBestStreak: String { t("최장 연속", "Best streak", "最長連続", "Mejor racha", "Meilleure série", "Melhor sequência", "Beste Serie", "Лучшая серия") }
    var recapGraduates: String { t("졸업", "Graduated", "卒業", "Graduados", "Diplômés", "Formados", "Abschlüsse", "Выпускники") }
    var recapNoData: String { t("기록 없음", "no data", "記録なし", "sin datos", "pas de données", "sem dados", "keine Daten", "нет данных") }
    func recapDays(_ count: Int) -> String {
        t("\(count)일", "\(count)d", "\(count)日", "\(count) d", "\(count) j", "\(count) d", "\(count) T", "\(count) дн.")
    }
    func recapBestDayLine(_ day: String, _ tokens: String) -> String {
        t("최고의 날은 \(day) — \(tokens) 토큰.",
          "Your best day was \(day) — \(tokens) tokens.",
          "最高の日は \(day)、\(tokens) トークン。",
          "Tu mejor día fue el \(day): \(tokens) tokens.",
          "Ton meilleur jour, c'était \(day) : \(tokens) tokens.",
          "Seu melhor dia foi \(day): \(tokens) tokens.",
          "Dein bester Tag war \(day) — \(tokens) Tokens.",
          "Лучший день — \(day), токенов: \(tokens).")
    }
    var recapNoGraduates: String {
        t("이 기간에 졸업한 디지몬이 없어요.", "No graduation in this period.", "この期間の卒業はありません。",
          "Ninguna graduación en este periodo.", "Aucun diplômé sur cette période.",
          "Nenhuma formatura neste período.", "Kein Abschluss in diesem Zeitraum.", "За этот период выпускников нет.")
    }

    var generalSectionTitle: String { t("일반", "General", "一般", "General", "Général", "Geral", "Allgemein", "Основные") }
    var menuBarSectionTitle: String { t("메뉴바에 표시", "Show in menu bar", "メニューバーに表示", "Mostrar en la barra de menús", "Afficher dans la barre des menus", "Mostrar na barra de menus", "In der Menüleiste anzeigen", "Показывать в строке меню") }
    var advancedSectionTitle: String { t("고급", "Advanced", "詳細", "Avanzado", "Avancé", "Avançado", "Erweitert", "Дополнительно") }
    var advancedDisclosureLabel: String { t("고급 설정 · 진단", "Advanced · diagnostics", "詳細設定・診断", "Avanzado · diagnóstico", "Avancé · diagnostics", "Avançado · diagnóstico", "Erweitert · Diagnose", "Дополнительно · диагностика") }
    var aboutSupportSectionTitle: String { t("정보 & 지원", "About & Support", "情報とサポート", "Acerca de y soporte", "À propos et assistance", "Sobre e suporte", "Info & Support", "О приложении и поддержка") }
    var quit: String { t("종료", "Quit", "終了", "Salir", "Quitter", "Encerrar", "Beenden", "Завершить") }

    // MARK: 설정
    var refreshInterval: String { t("새로고침 간격", "Refresh interval", "更新間隔", "Intervalo de actualización", "Intervalle d'actualisation", "Intervalo de atualização", "Aktualisierungsintervall", "Интервал обновления") }
    var language: String { t("언어", "Language", "言語", "Idioma", "Langue", "Idioma", "Sprache", "Язык") }
    var menuBarItems: String { t("메뉴바 표시 항목 (복수 선택)", "Menu bar items (multi-select)", "メニューバー表示項目（複数選択）", "Elementos de la barra de menús (selección múltiple)", "Éléments de la barre des menus (sélection multiple)", "Itens da barra de menus (seleção múltipla)", "Elemente der Menüleiste (Mehrfachauswahl)", "Элементы строки меню (можно несколько)") }
    var todayTokensShort: String { t("오늘 토큰", "Today's tokens", "本日のトークン", "Tokens de hoy", "Tokens du jour", "Tokens de hoje", "Heutige Tokens", "Токены за сегодня") }
    var todayCost: String { t("오늘 비용 ($)", "Today's cost ($)", "本日のコスト ($)", "Coste de hoy ($)", "Coût du jour ($)", "Custo de hoje ($)", "Heutige Kosten ($)", "Стоимость за сегодня ($)") }
    var limitPercent: String { t("한도 %", "Limit %", "上限 %", "Límite %", "Limite %", "Limite %", "Limit %", "Лимит, %") }
    var menuLimitColor: String {
        t("퍼센트 색상", "Percent color", "パーセントの色", "Color del porcentaje", "Couleur du pourcentage",
          "Cor da porcentagem", "Prozentfarbe", "Цвет процентов")
    }
    var menuLimitColorHint: String {
        t("팝오버 한도 게이지와 같은 색", "Same colors as the popover limit gauges",
          "ポップオーバーの上限ゲージと同じ色", "Los mismos colores que los medidores de límite",
          "Les mêmes couleurs que les jauges de limite", "As mesmas cores dos medidores de limite",
          "Dieselben Farben wie die Limit-Balken",
          "Те же цвета, что у шкал лимитов во всплывающем окне")
    }
    func menuLimitColorMode(_ mode: UsageStore.MenuLimitColorMode) -> String {
        switch mode {
        case .gauge:
            return t("게이지와 같게", "Match gauges", "ゲージと同じ", "Como los medidores",
                     "Comme les jauges", "Como os medidores", "Wie die Balken", "Как у шкал")
        case .attention:
            return t("주의 단계만", "Only when fast", "速いときだけ", "Solo si va rápido",
                     "Seulement si rapide", "Só quando rápido", "Nur wenn schnell", "Только при быстром темпе")
        case .off:
            return t("끔", "Off", "オフ", "Desactivado", "Désactivé", "Desligado", "Aus", "Выкл.")
        }
    }
    var animationQualityLabel: String { t("애니메이션", "Animation", "アニメーション", "Animación", "Animation", "Animação", "Animation", "Анимация") }
    var animationQualityHint: String {
        t("부드러울수록 배터리를 더 씁니다", "Smoother uses more battery",
          "滑らかにするとバッテリー消費が増えます", "Más fluido consume más batería",
          "Plus fluide consomme plus de batterie", "Mais fluido consome mais bateria",
          "Flüssigere Animationen verbrauchen mehr Batterie",
          "Чем плавнее, тем больше расход батареи")
    }
    var animationPowerSaver: String { t("배터리 절약", "Power saver", "バッテリー優先", "Ahorro de batería", "Économie d'énergie", "Economia de bateria", "Energiesparmodus", "Экономия энергии") }
    var animationBalanced: String { t("기본", "Balanced", "標準", "Equilibrado", "Équilibré", "Equilibrado", "Ausgewogen", "Баланс") }
    var animationSmooth: String { t("부드럽게", "Smooth", "滑らか", "Fluido", "Fluide", "Fluido", "Flüssig", "Плавность") }
    var limitDisplayModeLabel: String { t("한도 표시 방식", "Limit display", "上限の表示", "Visualización del límite", "Affichage de la limite", "Exibição do limite", "Limit-Anzeige", "Показ лимитов") }
    var limitDisplayUsed: String { t("사용량", "Used", "使用量", "Usado", "Utilisé", "Usado", "Verbraucht", "Потрачено") }
    var limitDisplayRemaining: String { t("남은 양", "Remaining", "残量", "Restante", "Restant", "Restante", "Verbleibend", "Осталось") }
    /// 팝오버 한도 행의 remaining 모드 표시 — %에 자기설명 접미사를 붙인다.
    func percentRemaining(_ percent: String) -> String {
        t("\(percent) 남음", "\(percent) left", "残り\(percent)", "\(percent) restante", "\(percent) restant", "\(percent) restante", "\(percent) übrig", "осталось \(percent)")
    }
    var allOffHint: String { t("전부 끄면 캐릭터만 표시됩니다", "All off shows only the character", "すべてオフにするとキャラクターのみ表示", "Si desactivas todo, solo se mostrará el personaje", "Tout désactiver n'affiche que le personnage", "Se desativar tudo, só o personagem aparece", "Wenn du alles ausschaltest, wird nur das Digimon angezeigt", "Если всё выключить, будет виден только персонаж") }
    // MARK: 설정 — 로그인·키체인·알림 (상류 플로팅 펫 절에서 옮김)
    var disableKeychain: String { t("Keychain 접근 끄기", "Disable Keychain access", "Keychainアクセスを無効化", "Desactivar acceso a Keychain", "Désactiver l'accès au Keychain", "Desativar acesso ao Keychain", "Keychain-Zugriff deaktivieren", "Отключить доступ к Связке ключей") }
    var disableKeychainHint: String { t("켜면 Keychain 접근 허용 팝업이 더 안 뜹니다 — 공식 한도(%)만 숨겨지고 토큰·비용은 그대로", "When on, no more Keychain permission pop-ups — only official limits (%) are hidden; tokens/cost stay", "オンにするとKeychain許可のポップアップが出なくなります — 公式上限(%)のみ非表示、トークン・費用はそのまま", "Al activarlo, ya no aparecerán los avisos de permiso de Keychain — solo se ocultan los límites oficiales (%), los tokens y el coste se mantienen", "Une fois activé, plus de pop-ups d'autorisation Keychain — seules les limites officielles (%) sont masquées ; les tokens et le coût restent visibles", "Ao ativar, os avisos de permissão do Keychain não aparecem mais — só os limites oficiais (%) ficam ocultos; tokens e custo continuam", "Wenn aktiviert, erscheinen keine Keychain-Berechtigungsfenster mehr – nur offizielle Limits (%) werden ausgeblendet; Tokens und Kosten bleiben sichtbar", "Если включено, запросов доступа к Связке ключей не будет — скрываются только официальные лимиты (%), токены и стоимость остаются") }
    var refreshLimitToken: String { t("한도 토큰 캐시 갱신", "Refresh limit token cache", "上限トークンキャッシュを更新", "Actualizar caché del token de límite", "Actualiser le cache du token de limite", "Atualizar cache do token de limite", "Limit-Token-Cache aktualisieren", "Обновить токен") }
    var onlyOnPress: String { t("누를 때만 Keychain 을 읽어요 — 자동 폴링은 안 읽어 팝업이 안 떠요. 토큰 만료 후 이 버튼으로 한도 갱신", "Reads Keychain only when pressed — auto-polling never does, so no pop-ups. Refresh limits here after the token expires", "押した時のみKeychainを読みます — 自動更新では読まずポップアップも出ません。トークン期限切れ後はこのボタンで上限を更新", "Solo lee Keychain al pulsar — el sondeo automático nunca lo hace, así que no aparecen avisos. Usa este botón para actualizar los límites tras la expiración del token", "Lit le Keychain uniquement sur appui — le polling automatique ne le fait jamais, donc pas de pop-up. Actualise les limites ici après l'expiration du token", "Só lê o Keychain quando você clica no botão — a atualização automática nunca lê, então não aparecem avisos. Use este botão para atualizar os limites depois que o token expirar", "Keychain wird nur auf Knopfdruck gelesen – die automatische Abfrage greift nicht darauf zu, daher gibt es keine Pop-ups. Aktualisiere die Limits hier, wenn das Token abgelaufen ist", "Связка ключей читается только по нажатию — автообновление её не трогает, поэтому запросов не будет. Обновите лимиты здесь, когда токен истечёт") }
    var launchAtLogin: String { t("로그인 시 자동 시작", "Launch at login", "ログイン時に自動起動", "Iniciar al arrancar sesión", "Lancer à l'ouverture de session", "Abrir ao iniciar sessão", "Bei der Anmeldung starten", "Запускать при входе в систему") }
    var bundledOnly: String { t(".app 번들로 설치된 경우에만 사용 가능", "Available only when installed as an .app bundle", ".appバンドルでインストールした場合のみ利用可能", "Disponible solo si se instaló como paquete .app", "Disponible uniquement si installé comme paquet .app", "Disponível apenas quando instalado como pacote .app", "Nur verfügbar, wenn die App als .app-Bundle installiert ist", "Доступно только при установке в виде .app") }
    var notificationsSection: String { t("알림", "Notifications", "通知", "Notificaciones", "Notifications", "Notificações", "Benachrichtigungen", "Уведомления") }

    // MARK: claude.ai 세션 키 (Keychain 프롬프트 없는 한도 경로)
    var sessionKeyLabel: String { t("claude.ai 세션 키", "claude.ai session key", "claude.ai セッションキー", "Clave de sesión de claude.ai", "Clé de session claude.ai", "Chave de sessão do claude.ai", "claude.ai-Sitzungsschlüssel", "Ключ сессии claude.ai") }
    var sessionKeyHint: String {
        t("Keychain 팝업 없이 공식 한도를 조회합니다. 브라우저 개발자도구 → Application → Cookies → claude.ai → sessionKey 값을 붙여넣으세요.",
          "Fetches official limits with no Keychain pop-up. Paste the value from DevTools → Application → Cookies → claude.ai → sessionKey.",
          "Keychain のポップアップなしで公式上限を取得します。開発者ツール → Application → Cookies → claude.ai → sessionKey の値を貼り付けてください。",
          "Obtiene los límites oficiales sin avisos de Keychain. Pega el valor de DevTools → Application → Cookies → claude.ai → sessionKey.",
          "Récupère les limites officielles sans pop-up Keychain. Colle la valeur depuis DevTools → Application → Cookies → claude.ai → sessionKey.",
          "Busca os limites oficiais sem avisos do Keychain. Cole o valor de DevTools → Application → Cookies → claude.ai → sessionKey.",
          "Ruft offizielle Limits ohne Keychain-Pop-up ab. Füge den Wert aus DevTools → Application → Cookies → claude.ai → sessionKey ein.",
          "Загружает официальные лимиты без запросов Связки ключей. Вставьте значение из DevTools → Application → Cookies → claude.ai → sessionKey.")
    }
    var sessionKeyPerAccountNote: String {
        t("기본 Claude 계정(~/.claude)에 적용됩니다. 다른 계정은 아래에서 각자 키를 넣을 수 있어요.",
          "Applies to the default Claude account (~/.claude). Each other account can have its own key below.",
          "デフォルトの Claude アカウント（~/.claude）に適用されます。ほかのアカウントは下でそれぞれキーを設定できます。",
          "Se aplica a la cuenta de Claude predeterminada (~/.claude). Cada una de las otras cuentas puede tener su propia clave abajo.",
          "Concerne le compte Claude principal (~/.claude). Chaque autre compte peut avoir sa propre clé ci-dessous.",
          "Aplica-se à conta padrão do Claude (~/.claude). Cada uma das outras contas pode ter a própria chave abaixo.",
          "Gilt für das Standard-Claude-Konto (~/.claude). Jedes weitere Konto kann unten einen eigenen Schlüssel haben.",
          "Действует для основного аккаунта Claude (~/.claude). Для остальных аккаунтов ниже можно задать отдельные ключи.")
    }
    /// An additional account's own key row: the account's tab title, or its folder before its limits load.
    func accountSessionKeyLabel(_ account: String) -> String {
        t("\(account) 세션 키", "Session key for \(account)", "\(account) のセッションキー",
          "Clave de sesión de \(account)", "Clé de session de \(account)", "Chave de sessão de \(account)",
          "Sitzungsschlüssel für \(account)",
          "Ключ сессии: \(account)")
    }
    /// 평문 보관을 숨기지 않는다 — 사용자가 무엇을 맡기는지, 어떻게 취소하는지 알아야 한다.
    var sessionKeyStorageNote: String {
        t("키는 이 Mac 의 앱 폴더에 본인만 읽을 수 있는 파일로 저장됩니다(암호화 아님). 브라우저에서 로그아웃하면 즉시 무효화됩니다.",
          "The key is stored in this Mac's app folder as an owner-only file (not encrypted). Logging out in your browser invalidates it immediately.",
          "キーはこの Mac のアプリフォルダに本人のみ読み取り可能なファイルとして保存されます(暗号化なし)。ブラウザでログアウトすると即時無効になります。",
          "La clave se guarda en la carpeta de la app de este Mac como archivo solo para el propietario (sin cifrar). Al cerrar sesión en el navegador se invalida de inmediato.",
          "La clé est enregistrée dans le dossier de l'app sur ce Mac, en fichier lisible par toi seul (non chiffré). Te déconnecter dans le navigateur l'invalide immédiatement.",
          "A chave fica na pasta do app neste Mac, em um arquivo que só você pode ler (sem criptografia). Sair da conta no navegador a invalida na hora.",
          "Der Schlüssel liegt im App-Ordner dieses Macs in einer Datei, die nur du lesen kannst (unverschlüsselt). Meldest du dich im Browser ab, wird er sofort ungültig.",
          "Ключ хранится в папке приложения на этом Mac в файле, доступном только владельцу (без шифрования). Выход из аккаунта в браузере сразу делает его недействительным.")
    }
    var sessionKeySaved: String { t("설정됨", "Saved", "設定済み", "Guardada", "Enregistrée", "Salva", "Gespeichert", "Сохранено") }
    var save: String { t("저장", "Save", "保存", "Guardar", "Enregistrer", "Salvar", "Speichern", "Сохранить") }
    var delete: String { t("삭제", "Delete", "削除", "Eliminar", "Supprimer", "Excluir", "Löschen", "Удалить") }
    var sessionKeyOrganizationLabel: String { t("조직", "Organization", "組織", "Organización", "Organisation", "Organização", "Organisation", "Организация") }
    var sessionKeyMalformedError: String {
        t("세션 키 형식이 아닙니다. sessionKey 쿠키 값 전체를 붙여넣었는지 확인하세요(sk-ant- 로 시작).",
          "That isn't a session key. Check you pasted the whole sessionKey cookie value (starts with sk-ant-).",
          "セッションキーの形式ではありません。sessionKey クッキーの値全体を貼り付けたか確認してください(sk-ant- で始まります)。",
          "Eso no es una clave de sesión. Comprueba que pegaste todo el valor de la cookie sessionKey (empieza por sk-ant-).",
          "Ce n'est pas une clé de session. Vérifie que tu as collé toute la valeur du cookie sessionKey (elle commence par sk-ant-).",
          "Isso não é uma chave de sessão. Confira se você colou todo o valor do cookie sessionKey (começa com sk-ant-).",
          "Das ist kein Sitzungsschlüssel. Prüfe, ob du den vollständigen Wert des sessionKey-Cookies eingefügt hast (beginnt mit sk-ant-).",
          "Это не ключ сессии. Проверьте, что вставили значение cookie sessionKey целиком (начинается с sk-ant-).")
    }
    var sessionKeyExpiredError: String {
        t("세션 키가 만료됐습니다. 브라우저에서 다시 복사해 붙여넣으세요.",
          "The session key expired. Copy a fresh one from your browser and paste it again.",
          "セッションキーの有効期限が切れました。ブラウザから再度コピーして貼り付けてください。",
          "La clave de sesión caducó. Copia una nueva desde el navegador y pégala otra vez.",
          "La clé de session a expiré. Copie-en une nouvelle depuis le navigateur et colle-la à nouveau.",
          "A chave de sessão expirou. Copie uma nova do navegador e cole de novo.",
          "Der Sitzungsschlüssel ist abgelaufen. Kopiere einen neuen aus deinem Browser und füge ihn erneut ein.",
          "Срок действия ключа сессии истёк. Скопируйте новый из браузера и вставьте снова.")
    }
    var sessionKeyNoOrgError: String {
        t("이 키로 한도를 볼 수 있는 조직이 없습니다.",
          "No organization on this key can show limits.",
          "このキーで上限を確認できる組織がありません。",
          "Ninguna organización de esta clave puede mostrar límites.",
          "Aucune organisation liée à cette clé ne peut afficher de limites.",
          "Nenhuma organização desta chave pode mostrar limites.",
          "Keine Organisation dieses Schlüssels kann Limits anzeigen.",
          "Ни одна организация с этим ключом не может показать лимиты.")
    }

    // MARK: 세션 키 만료 안내 — OAuth 만료와 처방이 다르므로 문구·행동을 따로 둔다
    var sessionKeyExpiredTitle: String {
        t("claude.ai 세션 키 만료 — 한도가 갱신 안 돼요",
          "claude.ai session key expired — limits aren't refreshing",
          "claude.ai セッションキーの期限切れ — 上限が更新されません",
          "La clave de sesión de claude.ai caducó: los límites no se actualizan",
          "Clé de session claude.ai expirée — les limites ne s'actualisent plus",
          "A chave de sessão do claude.ai expirou — os limites não estão atualizando",
          "claude.ai-Sitzungsschlüssel abgelaufen – Limits werden nicht aktualisiert",
          "Ключ сессии claude.ai истёк — лимиты не обновляются")
    }
    /// Keychain 재조회를 권하지 않는다 — 세션 키가 죽은 상태에서 그건 아무것도 고치지 못하고,
    /// 하필 세션 키로 피하려던 그 팝업을 띄운다.
    var sessionKeyExpiredNoticeHint: String {
        t("표시된 값은 만료 전 기준이에요. 브라우저에서 sessionKey 를 다시 복사해 설정 → 고급에 붙여넣으세요.",
          "The numbers shown are from before it expired. Copy a fresh sessionKey from your browser and paste it under Settings → Advanced.",
          "表示中の値は期限切れ前のものです。ブラウザから sessionKey を再度コピーし、設定 → 詳細に貼り付けてください。",
          "Los valores mostrados son anteriores a la caducidad. Copia una nueva sessionKey del navegador y pégala en Ajustes → Avanzado.",
          "Les valeurs affichées datent d'avant l'expiration. Copie une nouvelle sessionKey depuis ton navigateur et colle-la dans Réglages → Avancé.",
          "Os valores exibidos são de antes de expirar. Copie uma nova sessionKey do navegador e cole em Ajustes → Avançado.",
          "Die angezeigten Werte stammen von vor dem Ablauf. Kopiere einen neuen sessionKey aus deinem Browser und füge ihn unter Einstellungen → Erweitert ein.",
          "Показаны данные, полученные до истечения ключа. Скопируйте новый sessionKey из браузера и вставьте его в «Настройки → Дополнительно».")
    }
    var sessionKeyExpiredBadge: String {
        t("만료됨", "Expired", "期限切れ", "Caducada", "Expirée", "Expirada", "Abgelaufen", "Истёк")
    }

    // MARK: Claude Keychain 항상 허용 초기화 도움말 (상시 안내)
    var claudeKeychainHelpTitle: String {
        t("왜 주기적으로 암호를 묻나요?",
          "Why does it ask for password periodically?",
          "なぜ定期的にパスワードを求められるのですか？",
          "¿Por qué pide la contraseña periódicamente?",
          "Pourquoi le mot de passe est-il demandé périodiquement ?",
          "Por que pede a senha periodicamente?",
          "Warum wird regelmäßig nach dem Passwort gefragt?",
          "Почему периодически запрашивается пароль?")
    }
    var claudeKeychainHelpBody: String {
        t("Claude CLI가 백그라운드에서 토큰을 교체할 때 macOS 키체인의 '항상 허용' 권한이 초기화됩니다. 세션 키를 등록하면 암호 입력 없이 백그라운드 자동 갱신이 유지됩니다.",
          "When Claude CLI rotates tokens in the background, macOS resets the Keychain 'Always Allow' permission. Registering a session key keeps background limits refreshed without any password prompt.",
          "Claude CLI がバックグラウンドでトークンをローテーションすると、macOS Keychain の「常に許可」権限がリセットされます。セッションキーを登録すると、パスワード入力なしで自動更新が維持されます。",
          "Cuando Claude CLI rota tokens en segundo plano, macOS restablece el permiso 'Permitir siempre' del Llavero. Registrar una clave de sesión mantiene los límites actualizados sin pedir contraseña.",
          "Lorsque Claude CLI renouvelle les jetons en arrière-plan, macOS réinitialise l'autorisation 'Toujours autoriser'. L'enregistrement d'une clé de session permet de maintenir les limites à jour sans mot de passe.",
          "Quando o Claude CLI renova tokens em segundo plano, o macOS redefine a permissão 'Permitir Sempre'. Cadastrar uma chave de sessão mantém a atualização automática sem solicitar senha.",
          "Wenn Claude CLI Tokens im Hintergrund erneuert, setzt macOS die Berechtigung 'Immer erlauben' zurück. Ein registrierter Sitzungsschlüssel hält Limits ohne Passwortabfrage aktuell.",
          "Когда Claude CLI в фоне обновляет токены, macOS сбрасывает разрешение «Разрешать всегда» в Связке ключей. Если добавить ключ сессии, лимиты будут обновляться в фоне без запросов пароля.")
    }
    var registerSessionKey: String {
        t("세션 키 등록",
          "Register Session Key",
          "セッションキーを登録",
          "Registrar clave de sesión",
          "Enregistrer la clé de session",
          "Cadastrar chave de sessão",
          "Sitzungsschlüssel registrieren",
          "Добавить ключ сессии")
    }
    var claudeKeychainHelpTooltip: String {
        t("Claude 키체인 인증 안내",
          "Claude Keychain authentication info",
          "Claude Keychain 認証について",
          "Información de autenticación de Keychain de Claude",
          "Info sur l'authentification Keychain Claude",
          "Informações de autenticação do Keychain do Claude",
          "Claude Keychain-Authentifizierungsinformation",
          "Об авторизации Claude через Связку ключей")
    }

    var limitNotificationsLabel: String { t("한도 알림", "Limit alerts", "上限通知", "Alertas de límite", "Alertes de limite", "Alertas de limite", "Limit-Warnungen", "Оповещения о лимитах") }
    var companionNotificationsLabel: String { t("Companion 이벤트 (부화·진화·졸업)", "Companion events (hatch / evolve / graduate)", "コンパニオンイベント（孵化・進化・卒業）", "Eventos del compañero (eclosión / evolución / graduación)", "Événements du compagnon (éclosion / évolution / diplôme)", "Eventos do companheiro (nascimento / evolução / formatura)", "Begleiter-Ereignisse (Schlüpfen / Entwicklung / Abschied)", "События компаньона (вылупление / эволюция / выпуск)") }
    var statusChecksLabel: String { t("프로바이더 상태 확인", "Provider status checks", "プロバイダー状態チェック", "Comprobación de estado de proveedores", "Vérification de l'état des fournisseurs", "Verificação de status dos provedores", "Anbieterstatus prüfen", "Проверка статуса провайдеров") }
    var statusChecksHint: String { t("Claude·OpenAI 장애를 팝오버에 표시 (알림 아님)", "Show Claude / OpenAI incidents in the popover (not a notification)", "Claude・OpenAIの障害をポップオーバーに表示（通知ではない）", "Muestra incidentes de Claude/OpenAI en el popover (no es una notificación)", "Affiche les incidents Claude / OpenAI dans le popover (pas une notification)", "Mostra incidentes do Claude/OpenAI no painel (não é uma notificação)", "Störungen bei Claude / OpenAI im Popover anzeigen (keine Benachrichtigung)", "Показывать инциденты Claude / OpenAI во всплывающем окне (не уведомлением)") }
    var warning: String { t("경고", "Warning", "警告", "Aviso", "Avertissement", "Aviso", "Warnung", "Предупреждение") }
    var critical: String { t("임박", "Critical", "切迫", "Crítico", "Critique", "Crítico", "Kritisch", "Критично") }
    var aggregationNote: String { t("토큰 집계 기준: totalTokens (input + output + cache, 로컬 날짜)", "Token basis: totalTokens (input + output + cache, local date)", "集計基準: totalTokens (input + output + cache, ローカル日付)", "Base de cálculo: totalTokens (input + output + cache, fecha local)", "Base de calcul : totalTokens (input + output + cache, date locale)", "Base de cálculo: totalTokens (input + output + cache, data local)", "Token-Grundlage: totalTokens (input + output + cache, lokales Datum)", "Подсчёт токенов: totalTokens (ввод + вывод + кэш, по местной дате)") }
    var customScanProviderLabel: String { t("프로바이더", "Provider", "プロバイダー", "Proveedor", "Fournisseur", "Provedor", "Anbieter", "Провайдер") }
    var customScanRootsLabel: String { t("추가 스캔 폴더", "Additional scan folders", "追加スキャンフォルダ", "Carpetas de escaneo adicionales", "Dossiers d'analyse supplémentaires", "Pastas extras para escanear", "Zusätzliche Scan-Ordner", "Дополнительные папки для сканирования") }
    var customScanRootsHint: String {
        t("선택한 프로바이더의 로그가 기본 위치 밖에 있을 때만. 콤마·줄바꿈 구분, * 와일드카드. 다른 프로바이더 폴더를 넣지 마세요.",
          "Only for this provider's logs outside the built-in locations. Comma/newline separated, * wildcards. Do not point at another provider's folder.",
          "選択したプロバイダーのログが既定の場所にないときだけ。カンマ・改行区切り、*ワイルドカード。別プロバイダーのフォルダは指定しないでください。",
          "Solo para los registros de este proveedor fuera de las ubicaciones integradas. Separados por coma o salto de línea; comodines *. No indiques la carpeta de otro proveedor.",
          "Uniquement pour les journaux de ce fournisseur en dehors des emplacements intégrés. Séparés par des virgules ou des retours à la ligne ; caractères génériques *. N'indique pas le dossier d'un autre fournisseur.",
          "Só para os logs deste provedor fora dos locais padrão. Separados por vírgula ou quebra de linha; curingas *. Não aponte para a pasta de outro provedor.",
          "Nur für Protokolle dieses Anbieters außerhalb der Standardpfade. Durch Kommas oder Zeilenumbrüche getrennt, * als Platzhalter. Wähle keinen Ordner eines anderen Anbieters.",
          "Только для логов этого провайдера вне стандартных мест. Через запятую или с новой строки, поддерживается подстановка *. Не указывайте папку другого провайдера.")
    }
    var customScanRootsPlaceholder: String { t("~/path/to/sessions", "~/path/to/sessions", "~/path/to/sessions", "~/path/to/sessions", "~/path/to/sessions", "~/path/to/sessions", "~/path/to/sessions", "~/path/to/sessions") }
    func customScanRootsMatches(_ n: Int) -> String {
        t("지금 \(n)개 추가 폴더를 스캔함", "Scans \(n) extra folder(s) now", "現在\(n)個の追加フォルダをスキャン", "Escanea \(n) carpeta(s) extra ahora", "Analyse \(n) dossier(s) supplémentaire(s) maintenant", "Escaneando \(n) pasta(s) extra agora", "Zusätzlich gescannte Ordner: \(n)", "Сканируется дополнительных папок: \(n)")
    }
    // MARK: Additional Claude accounts (Settings → Advanced)
    var additionalClaudeAccountsLabel: String { t("추가 Claude 계정", "Additional Claude accounts", "追加のClaudeアカウント", "Cuentas de Claude adicionales", "Comptes Claude supplémentaires", "Contas extras do Claude", "Weitere Claude-Konten", "Дополнительные аккаунты Claude") }
    var additionalClaudeAccountsHint: String {
        t("다른 Claude Code 로그인(CLAUDE_CONFIG_DIR)은 ~/.claude-* 폴더와 export 된 CLAUDE_CONFIG_DIR 에서 자동으로 찾습니다. 다른 위치의 설정 폴더만 여기 추가하세요(콤마·줄바꿈 구분). 공식 한도에 계정마다 탭이 생기며, 수동 갱신 때 폴더마다 Keychain 접근을 물을 수 있습니다.",
          "Other Claude Code logins (CLAUDE_CONFIG_DIR) are detected in ~/.claude-* folders and from an exported CLAUDE_CONFIG_DIR. Add config folders stored elsewhere here, comma/newline separated. Each account gets its own tab in the official limits; a manual refresh may ask for Keychain access for each folder.",
          "他のClaude Codeログイン(CLAUDE_CONFIG_DIR)は ~/.claude-* フォルダと、エクスポートされた CLAUDE_CONFIG_DIR から自動検出されます。別の場所にある設定フォルダだけをここに追加してください(カンマ・改行区切り)。公式上限にアカウントごとのタブが追加され、手動更新時にフォルダごとにKeychainへのアクセスを確認することがあります。",
          "Los otros inicios de sesión de Claude Code (CLAUDE_CONFIG_DIR) se detectan en las carpetas ~/.claude-* y en un CLAUDE_CONFIG_DIR exportado. Añade aquí las carpetas de configuración guardadas en otro lugar, separadas por coma o salto de línea. Cada cuenta tiene su pestaña en los límites oficiales; una actualización manual puede pedir acceso a Keychain para cada carpeta.",
          "Les autres connexions Claude Code (CLAUDE_CONFIG_DIR) sont détectées dans les dossiers ~/.claude-* et depuis un CLAUDE_CONFIG_DIR exporté. Ajoute ici les dossiers de config rangés ailleurs, séparés par des virgules ou des retours à la ligne. Chaque compte a son onglet dans les limites officielles ; une actualisation manuelle peut demander l'accès au Keychain pour chaque dossier.",
          "Os outros logins do Claude Code (CLAUDE_CONFIG_DIR) são detectados nas pastas ~/.claude-* e num CLAUDE_CONFIG_DIR exportado. Adicione aqui pastas de configuração guardadas em outro lugar, separadas por vírgula ou quebra de linha. Cada conta ganha sua aba nos limites oficiais; uma atualização manual pode pedir acesso ao Keychain para cada pasta.",
          "Weitere Claude-Code-Anmeldungen (CLAUDE_CONFIG_DIR) werden in ~/.claude-*-Ordnern und über ein exportiertes CLAUDE_CONFIG_DIR erkannt. Füge hier Konfigurationsordner an anderen Orten hinzu, durch Kommas oder Zeilenumbrüche getrennt. Jedes Konto bekommt bei den offiziellen Limits einen eigenen Tab; eine manuelle Aktualisierung kann für jeden Ordner nach Keychain-Zugriff fragen.",
          "Другие входы в Claude Code (CLAUDE_CONFIG_DIR) находятся автоматически в папках ~/.claude-* и по экспортированной переменной CLAUDE_CONFIG_DIR. Папки конфигурации в других местах добавьте здесь — через запятую или с новой строки. У каждого аккаунта своя вкладка в официальных лимитах; при ручном обновлении может запрашиваться доступ к Связке ключей для каждой папки.")
    }
    func additionalClaudeAccountsDetected(_ folders: String) -> String {
        t("자동 감지: \(folders)", "Detected: \(folders)", "自動検出: \(folders)", "Detectadas: \(folders)", "Détectés : \(folders)", "Detectadas: \(folders)", "Erkannt: \(folders)", "Найдено: \(folders)")
    }
    var trackedAccountLabel: String { t("추적할 Claude 계정", "Tracked Claude account", "追跡する Claude アカウント", "Cuenta de Claude seguida", "Compte Claude suivi", "Conta do Claude acompanhada", "Verfolgtes Claude-Konto", "Отслеживаемый аккаунт Claude") }
    func trackedAccountToolTip(_ title: String) -> String {
        t("추적할 Claude 계정: \(title)", "Tracked Claude account: \(title)", "追跡する Claude アカウント: \(title)",
          "Cuenta de Claude seguida: \(title)", "Compte Claude suivi : \(title)",
          "Conta do Claude acompanhada: \(title)", "Verfolgtes Claude-Konto: \(title)", "Отслеживаемый аккаунт Claude: \(title)")
    }
    var trackedAccountHint: String {
        t("메뉴바 한도·경고 상태·컴패니언 기분·5시간 예측의 기준이에요.",
          "Drives the menu bar limit, warning state, companion mood and 5h forecast.",
          "メニューバーの上限・警告状態・コンパニオンの様子・5時間予測に使われます。",
          "Define el límite de la barra de menús, el estado de alerta, el ánimo del compañero y la previsión de 5 h.",
          "Pilote la limite de la barre des menus, l'état d'alerte, l'humeur du compagnon et la prévision 5 h.",
          "Define o limite na barra de menus, o estado de alerta, o humor do companheiro e a previsão de 5 h.",
          "Bestimmt das Limit in der Menüleiste, den Warnstatus, die Stimmung des Begleiters und die 5-Stunden-Prognose.",
          "Определяет лимит в строке меню, предупреждения, настроение компаньона и прогноз на 5 ч.")
    }
    var trackedAccountAutomatic: String { t("자동 (마지막 사용)", "Automatic (last used)", "自動（最後に使用）", "Automático (último usado)", "Automatique (dernier utilisé)", "Automático (último usado)", "Automatisch (zuletzt verwendet)", "Автоматически (последний активный)") }
    var trackedAccountHighest: String { t("사용률 최고", "Highest usage", "使用率が最大", "Mayor uso", "Le plus chargé", "Maior uso", "Höchste Auslastung", "Наибольший расход") }
    var additionalClaudeAccountsPlaceholder: String { t("~/.claude-work", "~/.claude-work", "~/.claude-work", "~/.claude-work", "~/.claude-work", "~/.claude-work", "~/.claude-work", "~/.claude-work") }
    func additionalClaudeAccountsFound(_ n: Int) -> String {
        t("계정 폴더 \(n)개 찾음", "\(n) account folder(s) found", "アカウントフォルダが\(n)個見つかりました", "\(n) carpeta(s) de cuenta encontrada(s)", "\(n) dossier(s) de compte trouvé(s)", "\(n) pasta(s) de conta encontrada(s)", "Gefundene Kontoordner: \(n)", "Найдено папок аккаунтов: \(n)")
    }
    var close: String { t("닫기", "Close", "閉じる", "Cerrar", "Fermer", "Fechar", "Schließen", "Закрыть") }

    // MARK: 문제점 알리기 (설정 → 메일 리포트)
    var reportProblem: String { t("문제점 알리기", "Report a problem", "問題を報告", "Reportar un problema", "Signaler un problème", "Relatar um problema", "Problem melden", "Сообщить о сбое") }
    var showLogFile: String { t("로그 파일 보기", "Show log file", "ログファイルを表示", "Mostrar archivo de registro", "Afficher le fichier journal", "Mostrar arquivo de log", "Protokolldatei anzeigen", "Показать файл журнала") }
    var reportAttachHint: String {
        t("메일에 로그 파일을 첨부해 주시면 원인 파악에 큰 도움이 돼요.",
          "Attaching the log file to the email helps a lot with diagnosis.",
          "メールにログファイルを添付していただくと原因の特定に役立ちます。",
          "Adjuntar el archivo de registro al correo ayuda mucho a diagnosticar el problema.",
          "Joindre le fichier journal au mail aide beaucoup au diagnostic.",
          "Anexar o arquivo de log ao e-mail ajuda muito no diagnóstico.",
          "Wenn du die Protokolldatei an die E-Mail anhängst, hilft das sehr bei der Fehlersuche.",
          "Файл журнала, приложенный к письму, очень помогает в диагностике.")
    }
    func reportMailFallback(_ address: String) -> String {
        t("메일 앱을 열 수 없어요. \(address) 로 직접 보내주세요.",
          "Couldn't open a mail app. Please email \(address) directly.",
          "メールアプリを開けません。\(address) 宛に直接お送りください。",
          "No se pudo abrir una app de correo. Escribe directamente a \(address).",
          "Impossible d'ouvrir une app de messagerie. Écris directement à \(address).",
          "Não foi possível abrir um app de e-mail. Escreva diretamente para \(address).",
          "Es konnte keine Mail-App geöffnet werden. Schreib bitte direkt an \(address).",
          "Не удалось открыть почтовое приложение. Напишите напрямую на \(address).")
    }
    func reportMailSubject(_ version: String) -> String {
        t("[DigimonTokenTamer] 문제 리포트 (v\(version))",
          "[DigimonTokenTamer] Problem report (v\(version))",
          "[DigimonTokenTamer] 問題レポート (v\(version))",
          "[DigimonTokenTamer] Reporte de problema (v\(version))",
          "[DigimonTokenTamer] Rapport de problème (v\(version))",
          "[DigimonTokenTamer] Relato de problema (v\(version))",
          "[DigimonTokenTamer] Problembericht (v\(version))",
          "[DigimonTokenTamer] Сообщение о проблеме (v\(version))")
    }
    func reportMailBody(version: String, os: String) -> String {
        t("""
        문제 내용:
        (겪으신 문제를 적어주세요 — 언제, 어떤 화면에서, 어떻게 되었는지)


        ---
        앱 버전: v\(version)
        macOS: \(os)
        로그 파일(첨부 권장): ~/Library/Logs/DigimonTokenTamer.log
        """,
        """
        What happened:
        (Describe the problem — when, on which screen, and what you saw)


        ---
        App version: v\(version)
        macOS: \(os)
        Log file (please attach): ~/Library/Logs/DigimonTokenTamer.log
        """,
        """
        問題の内容:
        （いつ・どの画面で・どうなったかをご記入ください）


        ---
        アプリのバージョン: v\(version)
        macOS: \(os)
        ログファイル（添付推奨）: ~/Library/Logs/DigimonTokenTamer.log
        """,
        """
        Descripción del problema:
        (Describe lo que ocurrió — cuándo, en qué pantalla y qué viste)


        ---
        Versión de la app: v\(version)
        macOS: \(os)
        Archivo de registro (se recomienda adjuntar): ~/Library/Logs/DigimonTokenTamer.log
        """,
        """
        Ce qui s'est passé :
        (Décris le problème — quand, sur quel écran, et ce que tu as vu)


        ---
        Version de l'app : v\(version)
        macOS: \(os)
        Fichier journal (à joindre de préférence) : ~/Library/Logs/DigimonTokenTamer.log
        """,
        """
        Descrição do problema:
        (Descreva o que aconteceu — quando, em qual tela e o que você viu)


        ---
        Versão do app: v\(version)
        macOS: \(os)
        Arquivo de log (anexe, por favor): ~/Library/Logs/DigimonTokenTamer.log
        """,
        """
        Was ist passiert:
        (Beschreibe das Problem – wann, auf welchem Bildschirm und was du gesehen hast)


        ---
        App-Version: v\(version)
        macOS: \(os)
        Protokolldatei (bitte anhängen): ~/Library/Logs/DigimonTokenTamer.log
        """,
        """
        Что произошло:
        (Опишите проблему — когда, на каком экране и что вы увидели)


        ---
        Версия приложения: v\(version)
        macOS: \(os)
        Файл журнала (приложите, пожалуйста): ~/Library/Logs/DigimonTokenTamer.log
        """)
    }

    /// 새로고침 간격 라벨 (초 단위 값 → 표시). 0 = 수동.
    func intervalLabel(_ seconds: TimeInterval) -> String {
        if seconds == 0 { return t("수동", "Manual", "手動", "Manual", "Manuel", "Manual", "Manuell", "Вручную") }
        let m = Int(seconds / 60)
        return t("\(m)분", "\(m) min", "\(m)分", "\(m) min", "\(m) min", "\(m) min", "\(m) Min.", "\(m) мин")
    }

    // MARK: Claude 한도 토큰 갱신 오류 (친절 안내)
    func limitRefreshHTTPError(_ status: Int) -> String {
        if status == 401 || status == 403 {
            return t(
                "Claude 자격증명이 만료됐거나 권한이 없어요 (\(status)). Claude Code 로그인을 확인하세요. Codex만 쓴다면 무시해도 됩니다 — Codex 한도는 따로 표시돼요.",
                "Claude credential is expired or unauthorized (\(status)). Check that you're signed in to Claude Code. If you only use Codex you can ignore this — Codex limits show separately.",
                "Claude の認証情報が期限切れか権限がありません (\(status))。Claude Code にサインインしているか確認してください。Codex のみ使用する場合は無視できます — Codex の上限は別に表示されます。",
                "La credencial de Claude expiró o no tiene permisos (\(status)). Comprueba que has iniciado sesión en Claude Code. Si solo usas Codex, puedes ignorar esto — los límites de Codex se muestran aparte.",
                "L'identifiant Claude a expiré ou n'est pas autorisé (\(status)). Vérifie que tu es connecté à Claude Code. Si tu n'utilises que Codex, ignore ceci — les limites Codex s'affichent séparément.",
                "A credencial do Claude expirou ou não tem permissão (\(status)). Verifique se você fez login no Claude Code. Se você só usa o Codex, pode ignorar — os limites do Codex aparecem à parte.",
                "Deine Claude-Anmeldedaten sind abgelaufen oder nicht berechtigt (\(status)). Prüfe, ob du bei Claude Code angemeldet bist. Wenn du nur Codex verwendest, kannst du das ignorieren – Codex-Limits werden separat angezeigt.",
                "Учётные данные Claude истекли или недействительны (\(status)). Проверьте, что вы вошли в Claude Code. Если вы пользуетесь только Codex, это можно игнорировать — лимиты Codex показываются отдельно.")
        }
        return t("Claude 한도 조회 실패 (\(status)).", "Failed to fetch Claude limits (\(status)).", "Claude の上限取得に失敗しました (\(status))。", "No se pudieron obtener los límites de Claude (\(status)).", "Échec de récupération des limites Claude (\(status)).", "Não foi possível obter os limites do Claude (\(status)).", "Claude-Limits konnten nicht abgerufen werden (\(status)).", "Не удалось получить лимиты Claude (\(status)).")
    }
    var limitRefreshNoCredential: String {
        t("Claude 자격증명을 찾지 못했어요. Claude Code 에 로그인하면 한도가 표시됩니다. Codex만 쓴다면 무시해도 돼요.",
          "No Claude credential found. Sign in to Claude Code to see limits. If you only use Codex you can ignore this.",
          "Claude の認証情報が見つかりません。Claude Code にサインインすると上限が表示されます。Codex のみなら無視して構いません。",
          "No se encontró ninguna credencial de Claude. Inicia sesión en Claude Code para ver los límites. Si solo usas Codex, puedes ignorar esto.",
          "Aucun identifiant Claude trouvé. Connecte-toi à Claude Code pour voir les limites. Si tu n'utilises que Codex, ignore ceci.",
          "Nenhuma credencial do Claude encontrada. Faça login no Claude Code para ver os limites. Se você só usa o Codex, pode ignorar.",
          "Keine Claude-Anmeldedaten gefunden. Melde dich bei Claude Code an, um Limits zu sehen. Wenn du nur Codex verwendest, kannst du das ignorieren.",
          "Учётные данные Claude не найдены. Войдите в Claude Code, чтобы видеть лимиты. Если вы пользуетесь только Codex, это можно игнорировать.")
    }
    var limitRefreshReauthNeeded: String {
        t("Claude 자격증명에 계정 로그인 정보가 없어요. Claude Code 에서 `/login` 으로 다시 로그인하면 한도가 표시됩니다.",
          "Your Claude credential has no account sign-in. Run `/login` in Claude Code to sign in again and limits will appear.",
          "Claude の認証情報にアカウントのサインインが含まれていません。Claude Code で `/login` を実行して再度サインインすると上限が表示されます。",
          "Tu credencial de Claude no tiene una sesión de cuenta asociada. Ejecuta `/login` en Claude Code para volver a iniciar sesión y ver los límites.",
          "Ton identifiant Claude n'a pas de connexion de compte. Lance `/login` dans Claude Code pour te reconnecter et les limites apparaîtront.",
          "A credencial do Claude não está associada a nenhuma conta. Rode `/login` no Claude Code para fazer login de novo — aí os limites aparecem.",
          "Deine Claude-Anmeldedaten enthalten keine Kontoanmeldung. Führe `/login` in Claude Code aus, um dich erneut anzumelden und die Limits anzuzeigen.",
          "В учётных данных Claude нет входа в аккаунт. Выполните `/login` в Claude Code, чтобы войти снова, — и лимиты появятся.")
    }
    var limitRefreshGeneric: String {
        t("Claude 한도 조회에 실패했어요. 잠시 후 다시 시도하세요.",
          "Couldn't fetch Claude limits. Please try again shortly.",
          "Claude の上限取得に失敗しました。しばらくして再試行してください。",
          "No se pudieron obtener los límites de Claude. Inténtalo de nuevo en unos momentos.",
          "Impossible de récupérer les limites Claude. Réessaie dans un instant.",
          "Não foi possível obter os limites do Claude. Tente de novo daqui a pouco.",
          "Claude-Limits konnten nicht abgerufen werden. Versuch es gleich noch einmal.",
          "Не удалось получить лимиты Claude. Попробуйте чуть позже.")
    }
    var limitRefreshRateLimited: String {
        t("Claude 한도 조회가 일시 제한됐어요 (429). 잠시 쉬었다가 자동으로 재시도합니다.",
          "Claude limit checks are temporarily rate-limited (429). Backing off and retrying automatically.",
          "Claude の上限取得が一時的に制限されています (429)。少し待って自動的に再試行します。",
          "Las comprobaciones de límites de Claude están temporalmente limitadas (429). Se reintentará automáticamente en breve.",
          "Les vérifications de limites Claude sont temporairement restreintes (429). Pause puis nouvelle tentative automatique.",
          "As consultas de limite do Claude estão com as requisições restringidas (429). Vamos aguardar e tentar de novo automaticamente.",
          "Claude-Limitabfragen sind vorübergehend eingeschränkt (429). Nach einer kurzen Pause wird es automatisch erneut versucht.",
          "Проверки лимитов Claude временно ограничены по частоте (429). Повторим автоматически с паузой.")
    }

    // MARK: Claude 세션 만료(401) 안내
    var claudeAuthExpiredTitle: String {
        t("Claude 세션 만료 — 한도가 갱신 안 돼요",
          "Claude session expired — limits can't refresh",
          "Claude セッション期限切れ — 上限を更新できません",
          "Sesión de Claude expirada — los límites no se pueden actualizar",
          "Session Claude expirée — les limites ne s'actualisent pas",
          "Sessão do Claude expirada — não dá para atualizar os limites",
          "Claude-Sitzung abgelaufen – Limits können nicht aktualisiert werden",
          "Сессия Claude истекла — лимиты не обновляются")
    }
    var claudeAuthExpiredHint: String {
        t("표시된 값은 만료 전 기준이에요. 다시 시도하거나, Claude Code 를 한 번 실행하면 자동 갱신됩니다.",
          "Values shown are from before expiry. Retry, or run Claude Code once to refresh automatically.",
          "表示値は期限切れ前のものです。再試行するか、Claude Code を一度実行すると自動更新されます。",
          "Los valores mostrados son de antes de la expiración. Reinténtalo, o ejecuta Claude Code una vez para actualizarlos automáticamente.",
          "Les valeurs affichées datent d'avant l'expiration. Réessaie, ou lance Claude Code une fois pour actualiser automatiquement.",
          "Os valores exibidos são de antes da expiração. Tente de novo ou rode o Claude Code uma vez para atualizá-los automaticamente.",
          "Die angezeigten Werte stammen von vor dem Ablauf. Versuch es erneut oder starte Claude Code einmal, um sie automatisch zu aktualisieren.",
          "Показаны данные до истечения сессии. Повторите попытку или один раз запустите Claude Code — сессия обновится автоматически.")
    }
    func additionalAccountExpiredHint(_ folder: String) -> String {
        t("CLAUDE_CONFIG_DIR=\(folder) 로 Claude Code 를 한 번 실행한 뒤 다시 시도하세요.",
          "Run Claude Code once with CLAUDE_CONFIG_DIR=\(folder), then retry.",
          "CLAUDE_CONFIG_DIR=\(folder) で Claude Code を一度実行してから再試行してください。",
          "Ejecuta Claude Code una vez con CLAUDE_CONFIG_DIR=\(folder) y reinténtalo.",
          "Lance Claude Code une fois avec CLAUDE_CONFIG_DIR=\(folder), puis réessaie.",
          "Rode o Claude Code uma vez com CLAUDE_CONFIG_DIR=\(folder) e tente de novo.",
          "Starte Claude Code einmal mit CLAUDE_CONFIG_DIR=\(folder) und versuch es dann erneut.",
          "Один раз запустите Claude Code с CLAUDE_CONFIG_DIR=\(folder), затем повторите попытку.")
    }
    var retry: String { t("다시 시도", "Retry", "再試行", "Reintentar", "Réessayer", "Tentar de novo", "Erneut versuchen", "Повторить") }

    // MARK: Antigravity 세션 만료(401) 안내 — Claude 쪽과 동일 문안 구조로 통일
    var antigravityAuthExpiredTitle: String {
        t("Antigravity 세션 만료 — 한도가 갱신 안 돼요",
          "Antigravity session expired — limits can't refresh",
          "Antigravity セッション期限切れ — 上限を更新できません",
          "Sesión de Antigravity expirada — los límites no se pueden actualizar",
          "Session Antigravity expirée — les limites ne s'actualisent pas",
          "Sessão do Antigravity expirada — não dá para atualizar os limites",
          "Antigravity-Sitzung abgelaufen – Limits können nicht aktualisiert werden",
          "Сессия Antigravity истекла — лимиты не обновляются")
    }
    var antigravityAuthExpiredHint: String {
        t("인증 토큰이 만료됐어요. 다시 시도하거나, Antigravity IDE 를 한 번 실행하면 자동 갱신됩니다.",
          "The auth token expired. Retry, or run Antigravity IDE once to refresh automatically.",
          "認証トークンの期限が切れました。再試行するか、Antigravity IDE を一度実行すると自動更新されます。",
          "El token de autenticación expiró. Reinténtalo, o ejecuta Antigravity IDE una vez para actualizarlo automáticamente.",
          "Le jeton d'authentification a expiré. Réessaie, ou lance Antigravity IDE une fois pour actualiser automatiquement.",
          "O token de autenticação expirou. Tente de novo, ou abra o Antigravity IDE uma vez para atualizar automaticamente.",
          "Das Authentifizierungs-Token ist abgelaufen. Versuch es erneut oder starte Antigravity IDE einmal, um es automatisch zu aktualisieren.",
          "Токен авторизации истёк. Повторите попытку или один раз запустите Antigravity IDE — токен обновится автоматически.")
    }

    // MARK: Cursor 공식 한도(월간 포함 allowance)
    var cursorMonthlyIncluded: String {
        t("월간 포함 allowance", "Monthly included", "月間 included", "Incluido mensual", "Inclus mensuel", "Incluso mensal", "Monatlich inklusive", "Включено в месяц")
    }
    var cursorAutoUsage: String {
        t("Auto 사용", "Auto usage", "Auto 使用", "Uso Auto", "Usage Auto", "Uso Auto", "Auto-Nutzung", "Расход Auto")
    }
    var cursorApiUsage: String {
        t("API 사용", "API usage", "API 使用", "Uso API", "Usage API", "Uso API", "API-Nutzung", "Расход API")
    }
    func cursorRemainingSpend(_ amount: String) -> String {
        t("\(amount) 남음", "\(amount) left", "残り \(amount)", "Quedan \(amount)", "Reste \(amount)", "Restam \(amount)", "\(amount) übrig", "Осталось \(amount)")
    }
    var cursorAuthExpiredTitle: String {
        t("Cursor 세션 만료 — 한도가 갱신 안 돼요",
          "Cursor session expired — limits can't refresh",
          "Cursor セッション期限切れ — 上限を更新できません",
          "Sesión de Cursor expirada — los límites no se pueden actualizar",
          "Session Cursor expirée — les limites ne s'actualisent pas",
          "Sessão do Cursor expirada — não dá para atualizar os limites",
          "Cursor-Sitzung abgelaufen – Limits können nicht aktualisiert werden",
          "Сессия Cursor истекла — лимиты не обновляются")
    }
    var cursorAuthExpiredHint: String {
        t("Cursor IDE 에 다시 로그인하거나, 다시 시도해 주세요.",
          "Sign in to Cursor IDE again, or retry.",
          "Cursor IDE に再度サインインするか、再試行してください。",
          "Vuelve a iniciar sesión en Cursor IDE o reinténtalo.",
          "Reconnecte-toi à Cursor IDE ou réessaie.",
          "Entre de novo no Cursor IDE ou tente de novo.",
          "Melde dich erneut in Cursor IDE an oder versuch es noch einmal.",
          "Снова войдите в Cursor IDE или повторите попытку.")
    }

    // MARK: 업데이트 알림
    func updateAvailable(_ version: String, current: String) -> String {
        t("🆕 v\(version) 사용 가능 (현재 \(current))",
          "🆕 v\(version) available (you have \(current))",
          "🆕 v\(version) が利用可能（現在 \(current)）",
          "🆕 v\(version) disponible (tienes \(current))",
          "🆕 v\(version) disponible (tu as \(current))",
          "🆕 v\(version) disponível (você tem \(current))",
          "🆕 v\(version) verfügbar (installiert: \(current))",
          "🆕 Доступна v\(version) (у вас \(current))")
    }
    var updateButton: String { t("업데이트", "Update", "更新", "Actualizar", "Mettre à jour", "Instalar", "Aktualisieren", "Обновить") }
    var skipThisVersion: String { t("이 버전 건너뛰기", "Skip this version", "このバージョンをスキップ", "Omitir esta versión", "Ignorer cette version", "Ignorar esta versão", "Diese Version überspringen", "Пропустить эту версию") }
    func skippedVersion(_ version: String) -> String {
        t("v\(version)을 건너뛰었어요",
          "You skipped v\(version)",
          "v\(version) をスキップしました",
          "Omitiste la v\(version)",
          "Tu as ignoré la v\(version)",
          "Você ignorou a v\(version)",
          "Du hast v\(version) übersprungen",
          "Вы пропустили v\(version)")
    }
    var showSkippedAgain: String { t("다시 알리기", "Show again", "もう一度表示", "Mostrar de nuevo", "Afficher à nouveau", "Mostrar de novo", "Wieder anzeigen", "Показать снова") }
    var updating: String { t("업데이트 중…", "Updating…", "更新中…", "Actualizando…", "Mise à jour…", "Atualizando…", "Wird aktualisiert…", "Обновление…") }
    var updateSectionTitle: String { t("업데이트", "Updates", "アップデート", "Actualizaciones", "Mises à jour", "Atualizações", "Aktualisierungen", "Обновления") }
    var updateNotificationsLabel: String { t("업데이트 알림", "Update notifications", "アップデート通知", "Notificaciones de actualización", "Notifications de mise à jour", "Notificações de atualização", "Hinweise auf Aktualisierungen", "Уведомления об обновлениях") }
    var checkForUpdatesLabel: String { t("업데이트 확인", "Check for updates", "アップデートを確認", "Buscar actualizaciones", "Rechercher des mises à jour", "Buscar atualizações", "Nach Aktualisierungen suchen", "Проверять обновления") }
    var checkNowButton: String { t("지금 확인", "Check now", "今すぐ確認", "Comprobar ahora", "Vérifier maintenant", "Buscar agora", "Jetzt prüfen", "Проверить сейчас") }
    func updateFound(_ version: String) -> String { t("새 버전 v\(version) 있어요", "Version \(version) is available", "バージョン \(version) が利用可能です", "La versión \(version) está disponible", "La version \(version) est disponible", "A versão \(version) está disponível", "Version \(version) ist verfügbar", "Доступна версия \(version)") }
    func upToDate(_ version: String) -> String { t("최신 버전이에요 (v\(version))", "You're on the latest (v\(version))", "最新です (v\(version))", "Tienes la última versión (v\(version))", "Tu as la dernière version (v\(version))", "Você está na última versão (v\(version))", "Du hast die neueste Version (v\(version))", "У вас последняя версия (v\(version))") }

    // MARK: 알림
    var notifCritical: String { t("한도 임박", "Limit imminent", "上限切迫", "Límite inminente", "Limite imminente", "Limite iminente", "Limit fast erreicht", "Лимит почти исчерпан") }
    var notifWarning: String { t("한도 경고", "Limit warning", "上限警告", "Aviso de límite", "Alerte de limite", "Aviso de limite", "Limit-Warnung", "Лимит близко") }
    func notifBody(_ name: String, _ percent: String) -> String {
        t("\(name) 한도 \(percent) 사용", "\(name) at \(percent)", "\(name) 上限 \(percent) 使用", "\(name) al \(percent)", "\(name) à \(percent)", "\(name) em \(percent)", "\(name): \(percent) verbraucht", "\(name): \(percent)")
    }
    var claudeFiveHour: String { t("Claude 5시간 세션", "Claude 5-hour session", "Claude 5時間セッション", "Sesión de 5 horas de Claude", "Session de 5 h de Claude", "Sessão de 5 horas do Claude", "Claude-5-Stunden-Sitzung", "Claude: 5-часовая сессия") }
    var claudeWeekly: String { t("Claude 주간", "Claude weekly", "Claude 週間", "Semanal de Claude", "Claude hebdo", "Semanal do Claude", "Claude – wöchentlich", "Claude: неделя") }
    var codexPersonalLimit: String { t("Codex 개인 한도", "Codex personal limit", "Codex 個人上限", "Límite personal de Codex", "Limite personnelle Codex", "Limite pessoal do Codex", "Persönliches Codex-Limit", "Личный лимит Codex") }

}


// Digimon interface additions use Korean copy with an explicit English fallback.
extension L {
    static let digimonInterfaceCopy: [String: String] = [
        "Loading artwork…": "이미지를 불러오는 중…",
        "Artwork could not be downloaded. Check your connection and retry.": "이미지를 받지 못했어요. 연결을 확인하고 다시 시도해 주세요.",
        "Retry": "다시 시도",

        "ALL SERVICES · DETAILS": "전체 서비스 · 상세 기록",
        "Collection records are retained. One item is consumed at evolution start; daily-token conditions are rechecked before starting.": "수집 기록은 소모하지 않습니다. 아이템은 진화 시작 시 1개 소모하며, 당일 토큰 조건은 시작 직전에 다시 확인합니다.",
        "Continue a special result": "특수 진화 후 이어 키우기",
        "Continue training": "이어 키우기",
        "Digimon": "디지몬",
        "Digimon evolution": "디지몬 진화",
        "Digimon information": "디지몬 정보",
        "EVOLUTION DATA": "진화 데이터",
        "EVOLUTION PATH": "진화 경로",
        "Evolution / continuation ready · {0}": "진화·이어 키우기 가능 · {0}",
        "Evolution and training": "진화·육성 관리",
        "Evolution screen": "진화 화면",
        "Fusion and item evolution require a manual start after meeting their conditions.": "융합·아이템 진화는 조건을 확인한 뒤 직접 시작합니다.",
        "Fusion, item, release, Burst and Bond evolution require a manual start after meeting their conditions.": "융합·아이템·해방·버스트·유대 진화는 조건을 충족한 뒤 직접 선택합니다.",
        "Home": "홈으로",
        "INCUBATION DATA": "부화 데이터",
        "Item evolution": "아이템 진화",
        "Jogress evolution": "조그레스 진화",
        "Moves": "필살기",
        "Moves · ": "필살기 · ",
        "No move information": "필살기 정보 없음",
        "No special evolution, continuation or stored training is available.": "현재 가능한 특수 진화·이어 키우기·보관 육성이 없습니다.",
        "Official Korean profile excerpt · wording follows the official translation.": "공식 한국어 도감 발췌 · 공식 사이트의 번역 표기를 따릅니다.",
        "Official profile classification · may differ from the game stage.": "공식 도감 분류 · 게임 성장 단계와 다를 수 있습니다.",
        "Official profile information is unavailable.": "공식 설명 정보가 제공되지 않았습니다.",
        "Only paths to uncollected ordinary forms are shown. Registered intermediate forms are free transit.": "미수집 일반 진화로 이어지는 경로만 표시합니다. 등록된 중간 형태는 무료로 경유합니다.",
        "Ordinary evolution · normal growth token requirements": "일반 진화 · 기존 성장 토큰 조건 적용",
        "PROCESSED DATA": "처리된 데이터",
        "Park the current Digimon to begin. Filling the final training gauge restores it automatically. Only the active partner grows.": "현재 디지몬을 보관하고 시작합니다. 최종 형태의 육성 게이지를 채우면 보관한 디지몬으로 자동 복귀합니다. 현재 개체만 토큰으로 성장합니다.",
        "Park the current Digimon. It returns automatically when training finishes.": "현재 디지몬을 보관합니다. 육성 완료 후 자동 복귀합니다.",
        "Parked partners do not grow.": "보관 중에는 성장하지 않습니다.",
        "Read the full official profile ↗": "공식 도감에서 전체 설명 보기 ↗",
        "Requirements not met": "조건 미충족",
        "Requirements · ": "진화 조건 · ",
        "Resume training": "육성 재개",
        "Source · ": "원본 · ",
        "Special evolution or continuation available": "특수 진화 또는 이어 키우기 가능",
        "Special evolution preserves current training. Continue or resume to park the current partner and switch.": "특수 진화는 현재 육성을 유지합니다. 이어 키우기·육성 재개는 기존 육성을 보관하고 대상을 전환합니다.",
        "Stored data · ": "보관 데이터 · ",
        "Stored training · 1 / 1": "보관 중인 육성 · 1 / 1",
        "Stored training · {0} / 1": "육성 보관 · {0} / 1",
        "TRAINING DATA": "육성 데이터",
        "This game variant has no separate profile; the official base-form profile is shown.": "이 게임 변형의 별도 프로필은 없어 기본형의 공식 정보를 표시합니다.",
        "Uncollected · ": "미수집 · ",
        "Use from evolution selection · one consumed at confirmation": "진화 선택 화면에서 사용 · 진화 확정 시 1개 소모",
        "Used for evolution": "진화 시 사용",
        "{0} until stored training resumes": "보관 육성 복귀까지 {0}",
    ]

    private static let digimonAdditionalCopy: [String: String] = [
        "X-Antibody A": "X항체 A",
        "X-Antibody S": "X항체 S",
        "Digi-Egg of Courage": "용기의 캡슐",
        "Digi-Egg of Friendship": "우정의 캡슐",
        "Digi-Egg of Miracles": "기적의 캡슐",
        "Digi-Egg of Love": "사랑의 캡슐",
        "Digi-Egg of Purity": "순수의 캡슐",
        "Digi-Egg of Knowledge": "지식의 캡슐",
        "Digi-Egg of Sincerity": "성실의 캡슐",
        "Digi-Egg of Hope": "희망의 캡슐",
        "Digi-Egg of Light": "빛의 캡슐",
        "Digi-Egg of Fate": "운명의 캡슐",
        "Digivice": "디지바이스",
        "A device for item evolution · Consumes 1 per evolution": "특정 아이템 진화에 사용하는 장치 · 진화 확정 시 1개 소모",
        "For X-evolution up to Mega · Consumes 1 per evolution": "궁극체 이하의 X진화에 사용 · 진화 확정 시 1개 소모",
        "For X-evolution at Ultra or above · Consumes 1 per evolution": "초궁극체 이상의 X진화에 사용 · 진화 확정 시 1개 소모",
        "Designated item evolution": "지정 아이템 진화",
        " · Consumes 1 per evolution": " · 진화 확정 시 1개 소모",
        "Consumes 1 per evolution": "진화 확정 시 1개 소모",
        "Free transit": "무료 경유",
        "Currently training": "현재 육성 중",
        "Cannot switch training right now.": "현재 전환할 수 없습니다.",
        "This Digimon is currently being trained.": "현재 육성 중입니다.",
        "Wait until the egg hatches before continuing training.": "알 상태에서는 이어 키우기를 시작할 수 없습니다. 부화 후 시작해 주세요.",
        "The storage slot is occupied. Resume stored training first.": "보관 슬롯 사용 중 · 새 이어 키우기를 시작할 수 없습니다.",
        "All ordinary descendants have been collected.": "일반 후속 진화를 모두 수집했습니다.",
        "Could not save the training switch. Your current partner is unchanged.": "육성 전환을 저장하지 못했습니다. 기존 육성은 유지됩니다.",
        "{0} · Register {1} in the Notebook": "{0} · {1} 도감 등록 필요",
        "Item information unavailable": "아이템 정보 미제공",
        "Requires 1 {0} · Owned: {1} · Consumes 1 per evolution": "{0} 1개 필요 · 보유 {1}개 · 진화 시 1개 소모",
        "{0} · Requires {1} combined tokens today · Current: {2}": "{0} · 당일 합산 {1} 이상 필요 · 현재 {2}",
        "Classification under review · Evolution unavailable": "분류 검토 중 · 진화 보류",
        "Ordinary growth · Game evolution route": "일반 성장 · 게임 진화 경로",
        "X-Antibody evolution": "아이템·X항체",
        "Data evolution": "아이템·데이터",
        "Spirit evolution": "아이템·스피릿",
        "Armor evolution": "아이템·캡슐",
        "Burst evolution": "일반·버스트",
        "Mode reversion": "일반·복귀",
        "Ordinary evolution": "일반·성장",
        "Bond evolution": "일반·유대",
        "Release evolution": "일반·해방",
        "Jogress · Power inheritance": "조그레스·힘 계승",
        "Official English profile excerpt · wording follows the official translation.": "공식 영문 도감 발췌 · 공식 번역의 표현을 따릅니다.",
    ]

    func digimonUI(_ english: String, _ arguments: [String] = []) -> String {
        var text = lang == .ko ? Self.digimonInterfaceCopy[english] ?? Self.digimonAdditionalCopy[english] ?? english : english
        for (index, value) in arguments.enumerated() {
            text = text.replacingOccurrences(of: "{\(index)}", with: value)
        }
        return text
    }
}
