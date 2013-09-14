(defproject toes "0.1.0-SNAPSHOT"
  :description "A tic-tac-toe game"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.5.1"]]
  :plugins [[lein-cljsbuild "0.3.2"]]
  :source-paths ["src/clj"]
  :cljsbuild
  {:builds
   [{:source-paths ["src/cljs"],
     :compiler
     {:pretty-print true,
      :output-to "resources/public/toes.js",
      :optimization :whitespace}}]}
  )


