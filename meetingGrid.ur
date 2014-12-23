functor Make(M : sig
                 con homeKey :: {Type}
                 con homeRest :: {Type}
                 constraint homeKey ~ homeRest
                 con homeKeyName :: Name
                 con homeOtherConstraints :: {{Unit}}
                 constraint [homeKeyName] ~ homeOtherConstraints
                 val home : sql_table (homeKey ++ homeRest) ([homeKeyName = map (fn _ => ()) homeKey] ++ homeOtherConstraints)

                 con awayKey :: {Type}
                 con awayRest :: {Type}
                 constraint awayKey ~ awayRest
                 con awayKeyName :: Name
                 con awayOtherConstraints :: {{Unit}}
                 constraint [awayKeyName] ~ awayOtherConstraints
                 val away : sql_table (awayKey ++ awayRest) ([awayKeyName = map (fn _ => ()) awayKey] ++ awayOtherConstraints)

                 con timeKey :: {Type}
                 con timeRest :: {Type}
                 constraint timeKey ~ timeRest
                 con timeKeyName :: Name
                 con timeOtherConstraints :: {{Unit}}
                 constraint [timeKeyName] ~ timeOtherConstraints
                 val time : sql_table (timeKey ++ timeRest) ([timeKeyName = map (fn _ => ()) timeKey] ++ timeOtherConstraints)
                 val timeKeyFl : folder timeKey
                 val timeKeyShow : show $timeKey

                 constraint homeKey ~ awayKey
                 constraint (homeKey ++ awayKey) ~ timeKey
             end) = struct

    open M

    table meeting : (homeKey ++ timeKey ++ awayKey)

    val timeOb [tab] [rest] [tables] [exps] [[tab] ~ tables] [timeKey ~ rest]
        : sql_order_by ([tab = timeKey ++ rest] ++ tables) exps =
        @Sql.order_by timeKeyFl
         (@Sql.some_fields [tab] [timeKey] ! ! timeKeyFl)
         sql_desc

    structure FullGrid = struct
        type t = _

        val create =
            q1 <- queryL1 (SELECT time.{{timeKey}}
                           FROM time
                           ORDER BY {{{timeOb}}});
            q2 <- queryL1 (SELECT *
                           FROM meeting
                           ORDER BY {{{timeOb}}});
            ms <- source q2;
            return {Times = q1, Meetings = ms}
            
        fun render t = <xml>
          <table>
            <tr>
              <th/>
              {List.mapX (fn tm => <xml><th>{[tm]}</th></xml>) t.Times}
            </tr>
          </table>
        </xml>
    end

end
