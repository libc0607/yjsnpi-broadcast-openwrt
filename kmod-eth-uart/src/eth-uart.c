/*
	This driver is from https://zhoujianshi.github.io/articles/2017/Linux%E4%B8%B2%E5%8F%A3%E7%BD%91%E5%8D%A1%EF%BC%88%E4%B8%80%EF%BC%89%E2%80%94%E2%80%94%E9%80%9A%E7%94%A8%E8%99%9A%E6%8B%9F%E7%BD%91%E5%8D%A1%E7%9A%84%E5%AE%9E%E7%8E%B0/index.html
	(in Chinese)
	Thanks to his great work.
	
	It creates a virtual net device called 'eth_uart' ('ifconfig eth_uart0' should work),
	and packets can be sent/received via write/read to '/proc/eth_uart0/uio' in userspace, 
	so we can easily use an uart-to-433/gprs module as a network adapter.
	
	And I had removed the zh-cn comments in the original code. 
	If you want to see how it works, see the link above.

	Dirty mod by Github @libc0607.
*/

#include <linux/poll.h>
#include <linux/errno.h>
#include <linux/module.h>
#include <linux/proc_fs.h>
#include <linux/semaphore.h>
#include <linux/netdevice.h>
#include <linux/etherdevice.h>

MODULE_LICENSE("GPL");

static struct net_device* sg_dev = 0;
static struct proc_dir_entry* sg_proc = 0;
static struct sk_buff* sg_frame = 0;
static struct semaphore sg_sem_has_frame;
static wait_queue_head_t sg_poll_queue;

static int eth_uart_send_packet(struct sk_buff* skb,struct net_device *dev)
{
    netif_stop_queue(sg_dev);
    sg_dev->stats.tx_packets++;
    sg_dev->stats.tx_bytes += skb->len;
    sg_frame = skb;
    up(&sg_sem_has_frame);
    wake_up(&sg_poll_queue);
    return 0;
}

static ssize_t eth_uart_uio_read(struct file* file, char* buf, size_t count, loff_t* offset)
{
	int len;
	
    if(file->f_flags & O_NONBLOCK)
    {
        if(down_trylock(&sg_sem_has_frame) != 0)
            return -EAGAIN;
    }
    else
    {
        if(down_interruptible(&sg_sem_has_frame) != 0)
        {
            printk("<eth-uart.ko> down() interrupted...\n");
            return -EINTR;
        }
    }
    len = sg_frame->len;
    if(count < len)
    {
        up(&sg_sem_has_frame);
        printk("<eth-uart.ko> no enough buffer to read the frame...\n");
        return -EFBIG;
    }
    copy_to_user(buf, sg_frame->data, len);
    dev_kfree_skb(sg_frame);
    sg_frame = 0;
    netif_wake_queue(sg_dev);
	
    return len;
}

static uint eth_uart_uio_poll(struct file* file, poll_table* queue)
{
	uint mask;
	
    poll_wait(file, &sg_poll_queue, queue);
    mask = POLLOUT | POLLWRNORM;
    if(sg_frame != 0)
        mask |= POLLIN | POLLRDNORM;
	
    return mask;
}

static ssize_t eth_uart_uio_write(struct file* file, const char* buf, size_t count, loff_t* offset)
{
    struct sk_buff* skb = dev_alloc_skb(count + 2);
	
    if(skb == 0)
    {
        printk("<eth-uart.ko> dev_alloc_skb() failed!\n");
        return -ENOMEM;
    }
    skb_reserve(skb, 2);
    copy_from_user(skb_put(skb, count), buf, count);
    skb->dev = sg_dev;
    skb->protocol = eth_type_trans(skb, sg_dev);
    skb->ip_summed = CHECKSUM_NONE;
    sg_dev->stats.rx_packets++;
    sg_dev->stats.rx_bytes += skb->len;
    netif_rx(skb);
	
    return count;
}

static struct net_device_ops sg_ops =
{
    .ndo_start_xmit = eth_uart_send_packet,
};

static struct file_operations sg_uio_ops =
{
    .owner = THIS_MODULE,
    .read = eth_uart_uio_read,
    .poll = eth_uart_uio_poll,
    .write = eth_uart_uio_write,
};

static int eth_uart_init(void)
{
    int ret = 0;
	struct proc_dir_entry* t_proc_uio;
	
    sg_dev = alloc_netdev(0, "eth_uart%d", NET_NAME_UNKNOWN, ether_setup);
    if(sg_dev == 0)
    {
        printk("<eth-uart.ko> alloc_netdev() failed!\n");
        ret = -EEXIST;
        goto err_1;
    }
    sg_dev->netdev_ops = &sg_ops;
    memcpy(sg_dev->dev_addr, "\xEC\xA8\x6B", 3);
    get_random_bytes((char*)sg_dev->dev_addr + 3, 3);
    ret = register_netdev(sg_dev);
    if(ret != 0)
    {
        printk("<eth-uart.ko> register_netdev() failed!\n");
        goto err_2;
    }

    sg_proc = proc_mkdir(sg_dev->name, 0);	// eth_uart*
    if(sg_proc == 0)
    {
        printk("<eth-uart.ko> proc_mkdir() failed!\n");
        ret = -EEXIST;
        goto err_3;
    }
    t_proc_uio = proc_create("uio", 0666, sg_proc, &sg_uio_ops);
    if(t_proc_uio == 0)
    {
        printk("<eth-uart.ko> proc_create() failed!\n");
        ret = -EEXIST;
        goto err_4;
    }
    sema_init(&sg_sem_has_frame, 0);
    init_waitqueue_head(&sg_poll_queue);
    return 0;
    err_4:
        remove_proc_entry(sg_dev->name, 0);
    err_3:
        unregister_netdev(sg_dev);
    err_2:
        free_netdev(sg_dev);
    err_1:
        ;
    return ret;
}

static void eth_uart_exit(void)
{
    remove_proc_entry("uio", sg_proc);
    remove_proc_entry(sg_dev->name, 0);
    unregister_netdev(sg_dev);
    free_netdev(sg_dev);
    if(sg_frame != 0)
        dev_kfree_skb(sg_frame);
}

module_init(eth_uart_init);
module_exit(eth_uart_exit);