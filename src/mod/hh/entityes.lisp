;; [[file:hh.org::*Сущности и автоматы][entity_and_automates]]
(in-package #:moto)

(define-entity profile "Сущность поисковые профили"
  ((id serial)
   (user-id integer)
   (name varchar)
   (search-query varchar)
   (ts-create bigint)
   (ts-last bigint)))

(make-profile-table)


(define-automat vacancy "Автомат вакансии"
  ((id serial)
   (profile-id integer)
   (name varchar)
   (rem-id integer)
   (rem-date varchar)
   (rem-employer-name varchar)
   (rem-employer-id (or db-null integer))
   (currency (or db-null varchar))
   (salary (or db-null integer))
   (salary-text (or db-null varchar))
   (contact (or db-null varchar))
   (text (or db-null varchar))
   (history (or db-null varchar))
   (reason (or db-null varchar))
   (ts-created (or db-null bigint))
   (ts-viewed (or db-null bigint)))
  (:offer :wait_result :refuse_applicant :refuse_employer :send_test :run_test :skype_interview :interview :wait_test :wait_skype_interview :wait_interview :called :favorited :responded :hidden :viewed :new :teaser)
  ((:teaser :new :parsing)
   (:new :viewed :view)
   (:viewed :new :renew)
   (:viewed :hidden :hide-after-view)
   (:hidden :viewed :restore-from-hidden-to-view)
   (:viewed :responded :send-respond-from-view)
   (:viewed :favorited :favor)
   (:favorited :responded :send-respond-from-favorited)
   (:favorited :viewed :unfavor)
   (:favorited :hidden :hide-after-favor)
   (:responded :called :call)
   (:called :wait_interview :invite-interview)
   (:called :wait_skype_interview :invite-skype-interview)
   (:called :wait_test :invite-test)
   (:wait_interview :interview :interview)
   (:wait_skype_interview :skype_interview :skype-interview)
   (:skype_interview :called :call-after-skype-interview)
   (:wait_test :run_test :execute-test)
   (:run_test :send_test :send-test)
   (:send_test :called :called-after-test)
   (:interview :refuse_employer :refuse-employer-after-interview)
   (:interview :refuse_applicant :refuse-applicant-after-interview)
   (:interview :wait_result :wait-result-after-interview)
   (:skype_interview :refuse_employer :refuse-employer-after-skype-interview)
   (:skype_interview :refuse_applicant :refuse-applicant-after-skype-interview)
   (:skype_interview :wait_result :wait-result-after-skype-interview)
   (:wait_result :interview :invite-next-interview)
   (:skype_interview :interview :invite-interview-after-skype)
   (:wait_result :offer :invite-offer)
   (:wait_result :refuse_employer :employer-refuse-after-wait-result)
   (:wait_result :refuse_applicant :applicant-refuse-after-wait-result)))
;; entity_and_automates ends here
