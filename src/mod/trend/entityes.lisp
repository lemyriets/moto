;; [[file:trend.org::*Сущности и автоматы][entity_and_automates]]
(in-package #:moto)

(define-entity cmpx "Сущность комплекса"
  ((id serial)
   (name varchar)
   (addr (or db-null varchar))
   (district-id (or db-null integer))
   (metro-id (or db-null integer))))

(make-cmpx-table)


(define-entity plex "Сущность очереди жилого комплекса"
  ((id serial)
   (cmpx-id integer)
   (name (or db-null varchar))
   (distance (or db-null varchar))
   (deadline-id (or db-null integer))
   (subsidy (or db-null boolean))
   (finishing (or db-null varchar))
   (ipoteka (or db-null boolean))
   (installment (or db-null boolean))))

(make-plex-table)


(define-entity crps "Сущность корпуса очереди жилого комплекса"
  ((id serial)
   (plex-id integer)
   (name (or db-null varchar))))

(make-crps-table)


(define-entity flat "Сущность планировки"
  ((id serial)
   (crps-id (or db-null integer))
   (rooms (or db-null integer))
   (area-sum (or db-null varchar))
   (area-living (or db-null varchar))
   (area-kitchen (or db-null varchar))
   (price (or db-null integer))
   (balcon (or db-null varchar))
   (sanuzel (or db-null boolean))))

(make-flat-table)


(define-entity city "Сущность города"
  ((id serial)
   (name varchar)))

(make-city-table)


(define-entity district "Сущность района"
  ((id serial)
   (name varchar)))

(make-district-table)


;; Районы города
(make-district :name "Адмиралтейский")
(make-district :name "Василеостровский")
(make-district :name "Выборгский")
(make-district :name "Калининский")
(make-district :name "Кировский")
(make-district :name "Колпинский")
(make-district :name "Красногвардейский")
(make-district :name "Красносельский")
(make-district :name "Кронштадтский")
(make-district :name "Курортный")
(make-district :name "Московский")
(make-district :name "Невский")
(make-district :name "Петроградский")
(make-district :name "Петродворцовый")
(make-district :name "Приморский")
(make-district :name "Пушкинский")
(make-district :name "Фрунзенский")
(make-district :name "Центральный")
(make-district :name "Всеволожкси")

;; Районы области
(make-district :name "Бокситогорский")
(make-district :name "Волосовский")
(make-district :name "Волховский")
(make-district :name "Всеволожский")
(make-district :name "Выборгский")
(make-district :name "Гатчинский")
(make-district :name "Кингисеппский")
(make-district :name "Киришский")
(make-district :name "Кировский")
(make-district :name "Лодейнопольский")
(make-district :name "Ломоносовский")
(make-district :name "Лужский")
(make-district :name "Подпорожский")
(make-district :name "Приозерский")
(make-district :name "Сланцевский")
(make-district :name "Тихвинский")
(make-district :name "Тосненский")

(define-entity metro "Сущность метро"
  ((id serial)
   (name varchar)))

(make-metro-table)


(make-metro :name "Автово")
(make-metro :name "Адмиралтейская")
(make-metro :name "Академическая")
(make-metro :name "Балтийская")
(make-metro :name "Бухарестская")
(make-metro :name "Василеостровская")
(make-metro :name "Владимирская")
(make-metro :name "Волковская")
(make-metro :name "Выборгская")
(make-metro :name "Горьковская")
(make-metro :name "Гостиный двор")
(make-metro :name "Гражданский проспект")
(make-metro :name "Девяткино")
(make-metro :name "Достоевская")
(make-metro :name "Елизаровская")
(make-metro :name "Звёздная")
(make-metro :name "Звенигородская")
(make-metro :name "Кировский завод")
(make-metro :name "Комендантский проспект")
(make-metro :name "Крестовский остров")
(make-metro :name "Купчино")
(make-metro :name "Ладожская")
(make-metro :name "Ленинский проспект")
(make-metro :name "Лесная")
(make-metro :name "Лиговский проспект")
(make-metro :name "Ломоносовская")
(make-metro :name "Маяковская")
(make-metro :name "Международная")
(make-metro :name "Московская")
(make-metro :name "Московские ворота")
(make-metro :name "Нарвская")
(make-metro :name "Невский проспект")
(make-metro :name "Новочеркасская")
(make-metro :name "Обводный канал")
(make-metro :name "Обухово")
(make-metro :name "Озерки")
(make-metro :name "Парк Победы")
(make-metro :name "Парнас")
(make-metro :name "Петроградская")
(make-metro :name "Пионерская")
(make-metro :name "Площадь Александра Невского")
(make-metro :name "Площадь Александра Невского")
(make-metro :name "Площадь Восстания")
(make-metro :name "Площадь Ленина")
(make-metro :name "Площадь Мужества")
(make-metro :name "Политехническая")
(make-metro :name "Приморская")
(make-metro :name "Пролетарская")
(make-metro :name "Проспект Большевиков")
(make-metro :name "Проспект Ветеранов")
(make-metro :name "Проспект Просвещения")
(make-metro :name "Пушкинская")
(make-metro :name "Рыбацкое")
(make-metro :name "Садовая")
(make-metro :name "Сенная площадь")
(make-metro :name "Спасская")
(make-metro :name "Спортивная")
(make-metro :name "Старая Деревня")
(make-metro :name "Технологический институт")
(make-metro :name "Технологический институт")
(make-metro :name "Удельная")
(make-metro :name "Улица Дыбенко")
(make-metro :name "Фрунзенская")
(make-metro :name "Чёрная речка")
(make-metro :name "Чернышевская")
(make-metro :name "Чкаловская")
(make-metro :name "Электросила")

(define-entity deadline "Сущность метро"
  ((id serial)
   (name varchar)))

(make-deadline-table)


(make-deadline :name "1 квартал 2015")
(make-deadline :name "2 квартал 2015")
(make-deadline :name "3 квартал 2015")
(make-deadline :name "4 квартал 2015")

(make-deadline :name "1 квартал 2016")
(make-deadline :name "2 квартал 2016")
(make-deadline :name "3 квартал 2016")
(make-deadline :name "4 квартал 2016")

(make-deadline :name "1 квартал 2017")
(make-deadline :name "2 квартал 2017")
(make-deadline :name "3 квартал 2017")
(make-deadline :name "4 квартал 2017")

(make-deadline :name "1 квартал 2018")
(make-deadline :name "2 квартал 2018")
(make-deadline :name "3 квартал 2018")
(make-deadline :name "4 квартал 2018")

(make-deadline :name "1 квартал 2019")
(make-deadline :name "2 квартал 2019")
(make-deadline :name "3 квартал 2019")
(make-deadline :name "4 квартал 2019")
;; entity_and_automates ends here
