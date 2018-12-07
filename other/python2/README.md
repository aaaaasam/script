### firewall

```text
   cp firewall.py /usr/local/bin/firewall
   chmod +x /usr/local/bin/firewall

   firewall [ -w | --work ]:
        monitor         监控
        del [ -i | --ip ] <xxx.xxx.xxx.xxx>
            从防火墙中删除某一个IP，并且重置该IP在当天中的错误登录记录值为0；
        add [ -i | --ip ] <xxx.xxx.xxx.xxx>
            添加一个IP到防火墙，禁止该IP地址访问服务器的22端口
   注：
    1、使用的iptables -I INPUT，所以INPUT链中至少应该有一条记录，否则不会生效；
    2、保持间隔时间和计划任务间隔时间一致，避免误封；
    3、错误登录次数阈值比较为大于，只有大于该数才会封禁；
```
