view: keyword_conversion_events {
  sql_table_name: `SA360.KeywordFloodlightAndDeviceStats_21700000000010391`
    ;;

  dimension_group: _data {
    hidden: yes
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year,
      day_of_month,
      day_of_week
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}._DATA_DATE ;;
  }

  dimension_group: _latest {
    hidden: yes
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}._LATEST_DATE ;;
  }

  dimension: account_id {
    hidden: yes
    type: string
    sql: ${TABLE}.accountId ;;
  }

  dimension: ad_group_id {
    hidden: yes
    type: string
    sql: ${TABLE}.adGroupId ;;
  }

  dimension: ad_id {
    hidden: yes
    type: string
    sql: ${TABLE}.adId ;;
  }

  dimension: advertiser_id {
    hidden: yes
    type: string
    sql: ${TABLE}.advertiserId ;;
  }

  dimension: agency_id {
    hidden: yes
    type: string
    sql: ${TABLE}.agencyId ;;
  }

  dimension: campaign_id {
    hidden: yes
    type: string
    sql: ${TABLE}.campaignId ;;
  }

  dimension_group: visit {
    hidden: yes
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.date ;;
  }

  dimension: device_segment {
    type: string
    sql: ${TABLE}.deviceSegment ;;
  }

  dimension: dfa_actions {
    hidden: yes
    type: number
    sql: ${TABLE}.dfaActions ;;
  }

  dimension: dfa_revenue {
    hidden: yes
    type: number
    sql: ${TABLE}.dfaRevenue ;;
  }

  dimension: dfa_transactions {
    hidden: yes
    type: number
    sql: ${TABLE}.dfaTransactions ;;
  }

  dimension: dfa_weighted_actions {
    hidden: yes
    type: number
    sql: ${TABLE}.dfaWeightedActions ;;
  }

  dimension: effective_bid_strategy_id {
    hidden: yes
    type: string
    sql: ${TABLE}.effectiveBidStrategyId ;;
  }

  dimension: floodlight_activity_id {
    hidden: yes
    type: string
    sql: ${TABLE}.floodlightActivityId ;;
  }

  dimension: floodlight_group_id {
    hidden: yes
    type: string
    sql: ${TABLE}.floodlightGroupId ;;
  }

  dimension: keyword_engine_id {
    hidden: yes
    type: string
    sql: ${TABLE}.keywordEngineId ;;
  }

  dimension: keyword_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.keywordId ;;
  }

  ##### Keyword Standard Metric Aggregates #####

  measure: total_actions {
    type: sum
    sql: ${dfa_actions} ;;
    drill_fields: [_data_date,total_actions]
  }

  measure: total_transactions {
    type: sum
    sql: ${dfa_transactions} ;;
    drill_fields: [_data_date,total_transactions]
  }

  measure: total_conversions {
    description: "Sum of Dfa Actions and Dfa Transactions"
    type: number
    sql: ${total_actions} + ${total_transactions} ;;
    drill_fields: [_data_date, keyword.keyword, total_conversions]
  }

  ##### Keyword Conversion Metrics #####

  measure: total_revenue {
    description: "Aggregate revenue generated by Campaign manager transactions."
    type: sum
    value_format_name: usd_0
    sql: ${dfa_revenue} ;;
    drill_fields: [_data_date, keyword.keyword, total_revenue]
  }

  measure: ROAS {
    label: "ROAS as a Percentage"
    description: "Associated revenue divided by the total cost"
    type: number
    value_format_name: percent_0
    sql: 1.0 * ${total_revenue} / NULLIF(${keyword_events.total_cost},0)  ;;
    drill_fields: [_data_date, keyword.keyword, ROAS, total_revenue, keyword_events.total_cost]
  }

  measure: cost_per_acquisition {
    label: "Cost per Acquisition (CPA)"
    description: "Average cost per conversion"
    type: number
    value_format_name: usd
    sql: ${keyword_events.total_cost}*1.0/NULLIF(${total_conversions},0) ;;
    drill_fields: [_data_date, keyword.keyword, cost_per_acquisition, keyword_events.total_cost, total_conversions]
  }

  measure: conversion_rate {
    description: "Conversions divided by Clicks"
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${total_actions} / NULLIF(${keyword_events.total_clicks},0)  ;;
    drill_fields: [_data_date, keyword.keyword, conversion_rate, total_actions, keyword_events.total_clicks]
  }

###################### Dynamic Measure ######################
# Link to example: https://googlemarscisandbox.cloud.looker.com/looks/10
  parameter: select_measure {
    view_label: "Dynamic Measure"
    type: string
    allowed_value: {label: "Total Actions" value: "Total Actions"}
    allowed_value: {label: "Total Transactions" value: "Total Transactions"}
    allowed_value: {label: "Total Conversions" value: "Total Conversions"}
  }
  measure: dynamic_measure {
    view_label: "Dynamic Measure"
    label_from_parameter: select_measure
    type: number
    sql:
      {% if select_measure._parameter_value == "'Total Actions'" %}
        ${total_actions}
      {% elsif select_measure._parameter_value == "'Total Transactions'" %}
        ${total_transactions}
      {% else %}
        ${total_conversions}
      {% endif %};;
    link: {
      label: "Click to Drill"
      url: "{% if select_measure._parameter_value == 'Total Actions' %} {{ total_actions._link }}
      {% elsif select_measure._parameter_value == 'Total Transactions' %} {{ total_transactions._link }}
      {% else %} {{ total_conversions._link }}
      {% endif %}"
    }
  }
###################### Close - Dynamic Measure ######################


###################### Period over Period Reporting Metrics ######################

  filter: this_period_filter {
    view_label: "Period over Period"
    group_label: "Arbitrary Period Comparisons"
    type: date
  }

  filter: prior_period_filter {
    view_label: "Period over Period"
    group_label: "Arbitrary Period Comparisons"
    type: date
  }

  dimension: days_from_start_first {
    view_label: "Period over Period"
    hidden: yes
    type: number
    sql: DATE_DIFF( ${_data_raw}, CAST({% date_start this_period_filter %} AS DATE), DAY) ;;
  }

  dimension: days_from_start_second {
    view_label: "Period over Period"
    hidden: yes
    type: number
    sql: DATE_DIFF(${_data_raw}, CAST({% date_start prior_period_filter %} AS DATE), DAY) ;;
  }

  dimension: days_from_period_start {
    view_label: "Period over Period"
    type: number
    sql:
      CASE
       WHEN ${days_from_start_first} >= 0
       THEN ${days_from_start_first}
       WHEN ${days_from_start_second} >= 0
       THEN ${days_from_start_second}
      END;;
  }

  dimension: period_selected {
    view_label: "Period over Period"
    type: string
    sql:
        CASE
          WHEN ${_data_raw} >=  DATE({% date_start this_period_filter %})
          AND ${_data_raw} <= DATE({% date_end this_period_filter %})
          THEN 'This Period'
          WHEN ${_data_raw} >=  DATE({% date_start prior_period_filter %})
          AND ${_data_raw} <= DATE({% date_end prior_period_filter %})
          THEN 'Prior Period'
          END ;;
  }
###################### Close - Period over Period Reporting Metrics ######################

}
